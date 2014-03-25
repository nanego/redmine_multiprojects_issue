require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/issues_controller_patch.rb'
require 'redmine_multiprojects_issue/issue_patch.rb'

class IssuesControllerTest < ActionController::TestCase

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles

  def test_post_create_should_send_a_notification_to_other_projects_users
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    assert_difference 'Issue.count' do
      post :create, :project_id => 1,
           :issue => {:tracker_id => 3,
                      :subject => 'This is the test_new issue',
                      :description => 'This is the description',
                      :priority_id => 5,
                      :estimated_hours => '',
                      :project_ids => [1, 5],
                      :custom_field_values => {'2' => 'Value for field 2'}}
    end
    assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id

    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert mail['bcc'].to_s.include?(User.find(2).mail)
    assert mail['bcc'].to_s.include?(User.find(3).mail)
    assert mail['bcc'].to_s.include?(User.find(1).mail) #admin, member, but his role has no view_issue permission
    assert !mail['bcc'].to_s.include?(User.find(8).mail) # member but notifications disabled
  end

  def test_post_create_should_NOT_send_a_notification_to_non_member_users
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
    assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id

    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert mail['bcc'].to_s.include?(User.find(2).mail)
    assert mail['bcc'].to_s.include?(User.find(3).mail)
    assert !mail['bcc'].to_s.include?(User.find(1).mail)
    assert !mail['bcc'].to_s.include?(User.find(8).mail)
  end

  def test_put_update_should_send_a_notification_to_members_on_other_projects
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
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert mail['bcc'].to_s.include?(User.find(2).mail)
    assert mail['bcc'].to_s.include?(User.find(3).mail)
    assert mail['bcc'].to_s.include?(User.find(1).mail)
    assert !mail['bcc'].to_s.include?(User.find(8).mail) # member but notifications disabled
  end

  def test_put_update_should_NOT_send_a_notification_to_non_member_users
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
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert mail['bcc'].to_s.include?(User.find(2).mail)
    assert mail['bcc'].to_s.include?(User.find(3).mail)
    assert !mail['bcc'].to_s.include?(User.find(1).mail)
    assert !mail['bcc'].to_s.include?(User.find(8).mail) # member but notifications disabled
  end

  def test_load_projects_selection
    @request.session[:user_id] = 2
    get :load_projects_selection, format: :js, :issue_id => 1, :project_id => 1
    assert_response :success
    assert_template 'load_projects_selection'
    assert_equal 'text/javascript', response.content_type
    assert_include "$('#ajax-modal')", response.body
    assert_not_nil assigns(:issue)
    assert_equal 1, assigns(:issue).id
    assert_equal 1, assigns(:project).id # test set_project private method
  end

  def test_put_update_should_create_journals_and_journal_details
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
    assert_equal new_projects_ids, Issue.find(1).project_ids

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
    assert_equal new_projects_ids, Issue.find(1).project_ids
  end

  def test_put_update_should_NOT_create_journals_and_journal_details_if_only_main_project_is_added_to_projects
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
    assert_equal new_projects_ids, Issue.find(1).project_ids
  end

end
