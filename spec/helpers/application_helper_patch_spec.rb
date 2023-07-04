require "spec_helper"
require 'redmine_multiprojects_issue/application_helper_patch'

describe ApplicationHelper, type: :helper do

  fixtures :projects, :enabled_modules, :users, :user_preferences, :members,
           :member_roles, :roles, :trackers, :issue_statuses,
           :issue_categories, :enumerations, :issues,
           :watchers, :custom_fields, :custom_values, :versions,
           :queries,
           :projects_trackers,
           :custom_fields_trackers,
           :workflows, :journals,
           :attachments, :time_entries

  

  describe 'render_project_nested_lists_by_attributes' do

    it "should return the same value of render_project_nested_lists" do
      User.current = User.find(1)
      st_origin = render_project_nested_lists(Project.all)
      st_simulated = render_project_nested_lists_by_attributes(Project.all.sort_by(&:lft).pluck(:id, :name, :status, :lft, :rgt))
      
      expect(st_origin).to eq(st_simulated)
    end
  end
end
