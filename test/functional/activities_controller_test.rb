require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/issue_patch.rb'

class ActivitiesControllerTest < ActionController::TestCase

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :groups_users,
           :enabled_modules,
           :journals, :journal_details

  def setup
    # new multiproject issue on project 2
    Issue.create!(created_on: 3.days.ago.to_s(:db),
                 project_id: 2,
                 updated_on: 1.day.ago.to_s(:db),
                 description: "Desc",
                 subject: "My title",
                 tracker_id: 1,
                 author_id: 1,
                 projects: [Project.find(2)])
  end

  def test_project_index_should_not_contain_activity_from_other_unrelated_projects
    @request.session[:user_id] = 2
    get :index, :id => 1, :with_subprojects => 0

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:events_by_day)
    assert_not_nil assigns(:project)

    assert_select "span.project", false, "This page must contain no project class when there is no multiproject issues related to the current project"
  end

end
