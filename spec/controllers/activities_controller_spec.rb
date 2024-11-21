require "rails_helper"
require_relative '../../lib/redmine_multiprojects_issue/issue_patch.rb'

describe ActivitiesController do
  render_views

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :groups_users,
           :enabled_modules,
           :journals, :journal_details

  before do
    # new multiproject issue on project 2
    project = Project.find(2)
    Issue.create!(created_on: 3.days.ago.to_s,
                  project_id: project.id,
                  updated_on: 1.day.ago.to_s,
                  description: "Desc",
                  subject: "My title",
                  tracker_id: 1,
                  author_id: 1,
                  projects: [project])
  end

  context "index page" do
    it "does not contain activity from other unrelated projects" do
      @request.session[:user_id] = 2
      get :index, params: {:id => 1, :with_subprojects => 0}

      expect(response).to be_successful
      assert_template 'index'
      refute_nil assigns(:events_by_day)
      refute_nil assigns(:project)

      assert_select "span.project", false, "This page must contain no project class when there is no multiproject issues related to the current project"
    end
  end

end
