require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/query_patch.rb'

class IssueQueryMultiprojectsPatchTest < ActiveSupport::TestCase
  def test_versions
    project = Project.find(1)
    query = IssueQuery.new(project: project)
    assert_not_nil query.versions
    query.versions.each do |v|
      assert_includes [project.id] | project.descendants.active.collect(&:id), v.project_id
    end
  end
end
