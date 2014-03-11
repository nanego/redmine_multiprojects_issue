require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/issues_controller_patch.rb'
require 'redmine_multiprojects_issue/issue_patch.rb'

class IssuesTest < ActionController::IntegrationTest

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  # create an issue with multiple projects
  def test_create_issue_with_multiple_projects
    log_user('jsmith', 'jsmith')
    get 'projects/1/issues/new', :tracker_id => '1'
    assert_response :success
    assert_template 'issues/new'

    post 'projects/1/issues', :tracker_id => "1",
         :issue => { :start_date => "2006-12-26",
                     :priority_id => "4",
                     :subject => "new multiproject test issue",
                     :category_id => "",
                     :description => "new issue",
                     :done_ratio => "0",
                     :due_date => "",
                     :assigned_to_id => "",
                     :project_ids => [2, 3, 4]
         },
         :custom_fields => {'2' => 'Value for field 2'}

    # find created issue
    issue = Issue.find_by_subject("new multiproject test issue")
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'jsmith', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal [1,2,3,4], issue.projects.collect(&:id)
  end

  # update an issue and set several projects
  def test_update_projects
    log_user('jsmith', 'jsmith')
    get 'issues/1/edit'
    assert_response :success
    assert_template 'issues/edit'

    put 'issues/1', {:issue => { :project_ids => [2, 3, 4]}, :project_id => 1 }

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'jsmith', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal [1,2,3,4], issue.projects.collect(&:id)
  end

end
