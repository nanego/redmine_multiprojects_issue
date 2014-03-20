require File.expand_path('../../test_helper', __FILE__)

require 'redmine_multiprojects_issue/issues_controller_patch.rb'
require 'redmine_multiprojects_issue/issue_patch.rb'
require 'redmine_multiprojects_issue/query_patch.rb'

class QueryPatchTest < ActiveSupport::TestCase
  include Redmine::I18n

  fixtures :projects, :enabled_modules, :users, :members,
           :member_roles, :roles, :trackers, :issue_statuses,
           :issue_categories, :enumerations, :issues,
           :watchers, :custom_fields, :custom_values, :versions,
           :queries,
           :projects_trackers,
           :custom_fields_trackers

  def test_issue_visibility_from_other_project

    #setup - create multiproject issue
    multiproject_issue = Issue.find(2)
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!
    assert Issue.find(2).projects.size > 1

    User.current = User.find(8)
    query = IssueQuery.new(:name => '_')
    filter = query.available_filters['project_id']
    assert_not_nil filter

    query.project = Project.find(5)
    result = query.issues
    assert result.present?

    assert_not_nil result.detect {|issue| !User.current.member_of?(issue.project) }
    assert_equal result.detect {|issue| !User.current.member_of?(issue.project) }, Issue.find(2)
  end

end
