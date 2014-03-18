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
    assert mail['bcc'].to_s.include?(User.find(1).mail)
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
    assert false # TODO
  end

  # The following methods are private but they are very complex so they should
  # be tested imho to ensure they don't break in the future. Maybe they are
  # fully tested above?? An other solution would be to isolate them in a service
  # object and unit test that object in isolation
  def test_set_projects
    assert false # TODO
  end

  def test_update_journal_with_projects
    assert false # TODO
  end

  def test_set_project
    # ok maybe this one is simple enough so it doesn't need extensive testing ;)
    assert false # TODO
  end
end
