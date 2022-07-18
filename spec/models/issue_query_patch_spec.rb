require "spec_helper"
require_relative '../../lib/redmine_multiprojects_issue/issue_query_patch.rb'

describe "IssueQueryMultiprojectsPatch" do
  it "should versions" do
    project = Project.find(1)
    query = IssueQuery.new(project: project)
    refute_nil query.versions
    query.versions.each do |v|
      assert_includes [project.id] | project.descendants.active.collect(&:id), v.project_id
    end
  end
end
