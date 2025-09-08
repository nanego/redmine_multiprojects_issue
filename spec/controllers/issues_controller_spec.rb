require "rails_helper"
require "active_support/testing/assertions"
require_relative '../../lib/redmine_multiprojects_issue/issues_controller_patch.rb'
require_relative '../../lib/redmine_multiprojects_issue/issue_patch.rb'

describe IssuesController, type: :controller do

  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets,
           :projects

  before(:each) do
    Role.find_by_name("Manager").add_permission! :link_other_projects_to_issue
    Role.find_by_name("Manager").add_permission! :view_related_issues_in_secondary_projects
  end

  it "should require correct permission when linking other projects during issue creation (:link_other_projects_to_issue)" do
    Role.find_by_name("Manager").remove_permission!(:link_other_projects_to_issue)
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    assert_difference 'Issue.count', 1 do
      post :create, params: { :project_id => 1,
                              :issue => { :tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :estimated_hours => '',
                                          :project_ids => [1, 5, 2],
                                          :custom_field_values => { '2' => 'Value for field 2' } } }
    end

    expect(Issue.last.project_ids).to be_empty
  end

  it "should post create should send a notification to other projects users" do
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    assert_difference 'Issue.count', 1 do
      post :create, params: { :project_id => 1,
                              :issue => { :tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :estimated_hours => '',
                                          :project_ids => [1, 5],
                                          :custom_field_values => { '2' => 'Value for field 2' } } }
    end
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 3

    mails = ActionMailer::Base.deliveries
    field = Redmine::VERSION::MAJOR >= 5 ? 'to' : 'bcc'
    notified_users = mails.map { |m| m[field].to_s }
    expect(notified_users).to include(User.find(2).mail)
    expect(notified_users).to include(User.find(3).mail)
    expect(notified_users).to include(User.find(1).mail) # admin, member, but his role has no view_issue permission
    expect(notified_users).to_not include(User.find(8).mail) # member but notifications disabled
  end

  it "should post create should NOT send a notification to non member users" do
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    assert_difference 'Issue.count' do
      post :create, params: { :project_id => 1,
                              :issue => { :tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :estimated_hours => '',
                                          :project_ids => [1, 2, 3, 4, 6], # user 1 is member of project 5 only
                                          :custom_field_values => { '2' => 'Value for field 2' } } }
    end
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 2

    mails = ActionMailer::Base.deliveries
    field = Redmine::VERSION::MAJOR >= 5 ? 'to' : 'bcc'
    notified_users = mails.map { |m| m[field].to_s }
    expect(notified_users).to include(User.find(2).mail)
    expect(notified_users).to include(User.find(3).mail)
    expect(notified_users).to_not include(User.find(1).mail)
    expect(notified_users).to_not include(User.find(8).mail)
  end

  it "should require correct permission when linking other projects during issue update" do
    Role.find_by_name("Manager").remove_permission!(:link_other_projects_to_issue)

    @request.session[:user_id] = 2
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(1)
    old_subject = issue.subject
    new_subject = 'Subject modified by IssuesControllerTest#test_post_edit'

    put :update, params: { :id => 1, :issue => { :subject => new_subject,
                                                 :priority_id => '6',
                                                 :project_ids => [1, 5],
                                                 :category_id => '1' # no change
    } }
    issue.reload

    expect(ActionMailer::Base.deliveries.size).to eq 2
    expect(issue.subject).to eq(new_subject)
    expect(issue.project_ids).to be_empty
  end

  it "should keep current current linked projects when user has no permission" do
    Role.find_by_name("Manager").remove_permission!(:link_other_projects_to_issue)
    @request.session[:user_id] = 2

    issue = Issue.find(1)
    issue.assignable_projects = [Project.first]
    issue.save!

    put :update, params: { :id => 1, :issue => { :subject => "new subject",
                                                 :priority_id => '6',
                                                 :project_ids => [1, 5],
                                                 :category_id => '1'
    } }
    issue.reload

    expect(issue.subject).to eq("new subject")
    expect(issue.project_ids).to eq([1])
  end

  it "should put update should send a notification to members on other projects" do
    @request.session[:user_id] = 2
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(1)
    old_subject = issue.subject
    new_subject = 'Subject modified by IssuesControllerTest#test_post_edit'

    put :update, params: { :id => 1, :issue => { :subject => new_subject,
                                                 :priority_id => '6',
                                                 :project_ids => [1, 5],
                                                 :category_id => '1' # no change
    } }
    expect(ActionMailer::Base.deliveries.size).to eq 3

    mails = ActionMailer::Base.deliveries
    field = Redmine::VERSION::MAJOR >= 5 ? 'to' : 'bcc'
    notified_users = mails.map { |m| m[field].to_s }
    expect(notified_users).to include(User.find(2).mail)
    expect(notified_users).to include(User.find(3).mail)
    expect(notified_users).to include(User.find(1).mail)
    expect(notified_users).to_not include(User.find(8).mail) # member but notifications disabled
  end

  it "should put update should NOT send a notification to non member users" do
    @request.session[:user_id] = 2
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(1)
    old_subject = issue.subject
    new_subject = 'Subject modified by IssuesControllerTest#test_post_edit'

    put :update, params: { :id => 1, :issue => { :subject => new_subject,
                                                 :priority_id => '6',
                                                 :project_ids => [1, 4],
                                                 :category_id => '1' # no change
    } }
    expect(ActionMailer::Base.deliveries.size).to eq 2

    mails = ActionMailer::Base.deliveries
    field = Redmine::VERSION::MAJOR >= 5 ? 'to' : 'bcc'
    notified_users = mails.map { |m| m[field].to_s }
    expect(notified_users).to include(User.find(2).mail)
    expect(notified_users).to include(User.find(3).mail)
    expect(notified_users).to_not include(User.find(1).mail)
    expect(notified_users).to_not include(User.find(8).mail) # member but notifications disabled
  end

  it "should load projects selection" do
    @request.session[:user_id] = 2

    allowed_projects = Project.all.sort_by(&:lft).pluck(:id, :name, :status, :lft, :rgt).to_json
    issue_projects = Project.all.sort_by(&:lft).pluck(:id, :name, :status, :lft, :rgt).to_json
    project_ids = Project.all.map(&:id)

    post :load_projects_selection,
         xhr: true,
         params: {
           format: :js,
           :issue_id => 1,
           :project_id => 1,
           :allowed_projects => allowed_projects,
           :issue_projects => issue_projects,
           :project_ids => project_ids }

    expect(response).to be_successful
    assert_template 'issues/_modal_select_projects'
    expect(response.media_type).to eq 'application/json'
    expect(response.body).to include(Project.find(1).name)
    refute_nil assigns(:issue)
    expect(assigns(:issue).id).to eq 1
    expect(assigns(:project).id).to eq 1 # test set_project private method)).to eq 1
  end

  it "should put update should create journals and journal details" do
    @request.session[:user_id] = 2

    issue = Issue.find(1)
    old_projects_ids = issue.project_ids
    new_projects_ids = [1, 5]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 2) do
        put :update, params: { :id => 1, :issue => { :priority_id => '6',
                                                     :project_ids => new_projects_ids,
                                                     :category_id => '1' # no change
        } }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids

    issue = Issue.find(1)
    old_projects_ids = issue.project_ids
    new_projects_ids = [1, 3]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 3) do
        # 3 changes: priority, added projects, deleted projects
        put :update, params: { :id => 1, :issue => { :priority_id => '4',
                                                     :project_ids => new_projects_ids,
                                                     :category_id => '1' # no change
        } }
      end
    end
    expect(Issue.find(1).project_ids.sort).to eq new_projects_ids
  end

  it "should put update should NOT create journals and journal details if only main project is added to projects" do
    @request.session[:user_id] = 2
    issue = Issue.find(1)
    old_projects_ids = issue.project_ids
    new_projects_ids = [issue.project_id]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 1) do
        put :update, params: { :id => 1, :issue => { :priority_id => '6',
                                                     :project_ids => new_projects_ids, # change, but no journal cause only main project
                                                     :category_id => '1' # no change
        } }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids
  end

  it "should put update status should not create projects journal details" do
    @request.session[:user_id] = 2

    # setup multiprojects issue
    new_projects_ids = [1, 5]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 2) do
        put :update, params: { :id => 1, :issue => { :priority_id => '6',
                                                     :project_ids => new_projects_ids,
                                                     :category_id => '1' # no change
        } }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 1) do
        put :update, params: { :id => 1, :issue => { :status_id => '6' } }
      end
    end

    updated_issue = Issue.find(1)
    expect(new_projects_ids).to eq updated_issue.project_ids
    expect(6).to eq updated_issue.status_id

  end

  it "should edit link when issue allows answers on secondary projects" do
    prepare_context_where_user_can_only_update_through_secondary_project
    # normally we shouldn't see a link without our Issue#editable? patch!
    get :show, params: { :id => @issue.id }
    assert_select 'div.contextual a.icon-edit'
  end

  it "should edit link when issue doesnt answers on secondary projects" do
    prepare_context_where_user_can_only_update_through_secondary_project
    # no link, since the issue doesn't authorize editing..!
    @issue.update_attribute(:answers_on_secondary_projects, false)
    get :show, params: { :id => @issue.id }
    assert_select 'div.contextual a.icon-edit', :count => 0

  end

  it "should authorization patch that allows answers on secondary projects" do
    prepare_context_where_user_can_only_update_through_secondary_project
    assert_difference 'Journal.count', 1 do
      put :update, params: { :id => @issue.id, :issue => { :notes => 'bla bla bla' } }
    end
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => @issue.id)
    expect(@issue.reload.journals.last.notes).to eq 'bla bla bla'
  end

  context "when parameter project_ids is blank or user has no permission to use it" do

    it "keeps current linked projects when user has no permission" do
      Role.find_by_name("Manager").remove_permission!(:link_other_projects_to_issue)
      @request.session[:user_id] = 2

      issue = Issue.find(1)
      issue.assignable_projects = [Project.first]
      issue.save!

      put :update, params: { :id => 1, :issue => { :subject => "new subject",
                                                   :priority_id => '6',
                                                   :project_ids => [1, 5],
                                                   :category_id => '1'
      } }
      issue.reload

      expect(issue.subject).to eq("new subject")
      expect(issue.project_ids).to eq([1])
    end

    it "preserves existing associated projects when no project_ids parameter is provided" do
      @request.session[:user_id] = 2

      issue = Issue.find(1)
      initial_projects = [Project.find(1), Project.find(2)]
      issue.assignable_projects = initial_projects
      issue.save!

      initial_project_ids = issue.reload.project_ids
      expect(initial_project_ids).to include(1, 2)

      # Update the issue WITHOUT providing project_ids
      put :update, params: {
        :id => 1,
        :issue => {
          :subject => "Updated subject without project_ids",
          :priority_id => '6',
          :category_id => '1'
        }
      }

      issue.reload

      expect(issue.subject).to eq("Updated subject without project_ids")

      expect(issue.project_ids.sort).to eq(initial_project_ids.sort)
    end

    it "preserves existing associated projects when user has limited permissions and no project_ids is provided" do
      Role.find_by_name("Manager").remove_permission!(:link_other_projects_to_issue)
      @request.session[:user_id] = 2

      issue = Issue.find(1)
      initial_projects = [Project.find(1), Project.find(2)]
      issue.assignable_projects = initial_projects
      issue.save!

      initial_project_ids = issue.reload.project_ids
      expect(initial_project_ids).to include(1, 2)

      # Update the issue WITHOUT providing project_ids
      put :update, params: {
        :id => 1,
        :issue => {
          :subject => "Updated subject with limited permissions",
          :priority_id => '6',
          :category_id => '1'
        }
      }

      issue.reload

      expect(issue.subject).to eq("Updated subject with limited permissions")

      expect(issue.project_ids.sort).to eq(initial_project_ids.sort)
    end

  end

  private

  def prepare_context_where_user_can_only_update_through_secondary_project
    @user, @issue, @secondary_project = User.find(6), Issue.find(4), Project.find(3)
    Role.find(5).add_permission! :view_related_issues_in_secondary_projects # Role Anonymous
    @request.session[:user_id] = @user.id
    @issue.update_attribute(:project_ids, [@secondary_project.id])
    @issue.reload
  end

end
