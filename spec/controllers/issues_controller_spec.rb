require "spec_helper"
require "active_support/testing/assertions"
require 'redmine_multiprojects_issue/issues_controller_patch.rb'
require 'redmine_multiprojects_issue/issue_patch.rb'

describe IssuesController, type: :controller do

  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :issues,
           :workflows,
           :members,
           :member_roles,
           :enabled_modules,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers

  it "should post create should send a notification to other projects users" do
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    assert_difference 'Issue.count', 1 do
      post :create, :project_id => 1,
           :issue => {:tracker_id => 3,
                      :subject => 'This is the test_new issue',
                      :description => 'This is the description',
                      :priority_id => 5,
                      :estimated_hours => '',
                      :project_ids => [1, 5],
                      :custom_field_values => {'2' => 'Value for field 2'}}
    end
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 1

    mail = ActionMailer::Base.deliveries.last
    expect(mail['bcc'].to_s).to include(User.find(2).mail)
    expect(mail['bcc'].to_s).to include(User.find(3).mail)
    expect(mail['bcc'].to_s).to include(User.find(1).mail) #admin, member, but his role has no view_issue permission
    expect(mail['bcc'].to_s).to_not include(User.find(8).mail) # member but notifications disabled
  end

  it "should post create should NOT send a notification to non member users" do
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    assert_difference 'Issue.count' do
      post :create, :project_id => 1,
           :issue => {:tracker_id => 3,
                      :subject => 'This is the test_new issue',
                      :description => 'This is the description',
                      :priority_id => 5,
                      :estimated_hours => '',
                      :project_ids => [1, 2, 3, 4, 6], # user 1 is member of project 5 only
                      :custom_field_values => {'2' => 'Value for field 2'}}
    end
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 1

    mail = ActionMailer::Base.deliveries.last
    expect(mail['bcc'].to_s).to include(User.find(2).mail)
    expect(mail['bcc'].to_s).to include(User.find(3).mail)
    expect(mail['bcc'].to_s).to_not include(User.find(1).mail)
    expect(mail['bcc'].to_s).to_not include(User.find(8).mail)
  end

  it "should put update should send a notification to members on other projects" do
    @request.session[:user_id] = 2
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(1)
    old_subject = issue.subject
    new_subject = 'Subject modified by IssuesControllerTest#test_post_edit'

    put :update, :id => 1, :issue => {:subject => new_subject,
                                      :priority_id => '6',
                                      :project_ids => [1, 5],
                                      :category_id => '1' # no change
    }
    expect(ActionMailer::Base.deliveries.size).to eq 1

    mail = ActionMailer::Base.deliveries.last
    expect(mail['bcc'].to_s).to include(User.find(2).mail)
    expect(mail['bcc'].to_s).to include(User.find(3).mail)
    expect(mail['bcc'].to_s).to include(User.find(1).mail)
    expect(mail['bcc'].to_s).to_not include(User.find(8).mail) # member but notifications disabled
  end

  it "should put update should NOT send a notification to non member users" do
    @request.session[:user_id] = 2
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(1)
    old_subject = issue.subject
    new_subject = 'Subject modified by IssuesControllerTest#test_post_edit'

    put :update, :id => 1, :issue => {:subject => new_subject,
                                      :priority_id => '6',
                                      :project_ids => [1, 4],
                                      :category_id => '1' # no change
    }
    expect(ActionMailer::Base.deliveries.size).to eq 1

    mail = ActionMailer::Base.deliveries.last
    expect(mail['bcc'].to_s).to include(User.find(2).mail)
    expect(mail['bcc'].to_s).to include(User.find(3).mail)
    expect(mail['bcc'].to_s).to_not include(User.find(1).mail)
    expect(mail['bcc'].to_s).to_not include(User.find(8).mail) # member but notifications disabled
  end

  it "should load projects selection" do
    @request.session[:user_id] = 2
    get :load_projects_selection, format: :js, :issue_id => 1, :project_id => 1
    expect(response).to be_success
    assert_template 'load_projects_selection'
    expect(response.content_type).to eq 'text/javascript'
    expect(response.body).to include("$('#ajax-modal')")
    refute_nil assigns(:issue)
    expect(assigns(:issue).id).to eq 1
    expect(assigns(:project).id).to eq 1 # test set_project private method)).to eq 1
  end

  it "should put update should create journals and journal details" do
    @request.session[:user_id] = 2

    issue = Issue.find(1)
    old_projects_ids = issue.project_ids
    new_projects_ids = [1, 4, 5]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 2) do
        put :update, :id => 1, :issue => {:priority_id => '6',
                                          :project_ids => new_projects_ids,
                                          :category_id => '1' # no change
        }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids

    issue = Issue.find(1)
    old_projects_ids = issue.project_ids
    new_projects_ids = [1, 6]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 3) do # 3 changes : priority, added projects, deleted projects
        put :update, :id => 1, :issue => {:priority_id => '4',
                                           :project_ids => new_projects_ids,
                                           :category_id => '1' # no change
        }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids
  end

  it "should put update should NOT create journals and journal details if only main project is added to projects" do
    @request.session[:user_id] = 2
    issue = Issue.find(1)
    old_projects_ids = issue.project_ids
    new_projects_ids = [issue.project_id]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 1) do
        put :update, :id => 1, :issue => {:priority_id => '6',
                                          :project_ids => new_projects_ids, #change, but no journal cause only main project
                                          :category_id => '1' # no change
        }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids
  end

  it "should put update status should not create projects journal details" do
    @request.session[:user_id] = 2

    #setup multiprojects issue
    new_projects_ids = [1, 4, 5]
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 2) do
        put :update, :id => 1, :issue => {:priority_id => '6',
                                          :project_ids => new_projects_ids,
                                          :category_id => '1' # no change
        }
      end
    end
    expect(Issue.find(1).project_ids).to eq new_projects_ids

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 1) do
        put :update, :id => 1, :issue => {:status_id => '6'}
      end
    end

    updated_issue = Issue.find(1)
    expect(new_projects_ids).to eq updated_issue.project_ids
    expect(6).to eq updated_issue.status_id

  end

  it "should edit link when issue allows answers on secondary projects" do
    prepare_context_where_user_can_only_update_through_secondary_project
    #normally we shouldn't see a link without our Issue#editable? patch!
    get :show, :id => @issue.id
    assert_select 'div.contextual a.icon-edit'
  end

  it "should edit link when issue doesnt answers on secondary projects" do
    prepare_context_where_user_can_only_update_through_secondary_project
    #no link, since the issue doesn't authorize editing..!
    @issue.update_attribute(:answers_on_secondary_projects, false)
    get :show, :id => @issue.id
    assert_select 'div.contextual a.icon-edit', :count => 0

  end

  it "should authorization patch that allows answers on secondary projects" do
    prepare_context_where_user_can_only_update_through_secondary_project
    assert_difference 'Journal.count', 1 do
      put :update, :id => @issue.id, :issue => {:notes => 'bla bla bla'}
    end
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => @issue.id)
    expect(@issue.reload.journals.last.notes).to eq 'bla bla bla'
  end

  private

    def prepare_context_where_user_can_only_update_through_secondary_project
      @user, @issue, @secondary_project = User.find(6), Issue.find(4), Project.find(3)
      @request.session[:user_id] = @user.id
      @issue.update_attribute(:project_ids, [@secondary_project.id])
      @issue.reload
    end

end
