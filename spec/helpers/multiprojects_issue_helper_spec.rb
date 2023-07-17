require "spec_helper"

describe "MultiprojectsIssueHelper" do
  include MultiprojectsIssueHelper

  it "should custom_values_by_project_ids" do
    project_ids = Project.all.map(&:id)
    projects_arrray = Project.find(project_ids).pluck(:id, :name, :status, :lft, :rgt).to_a
    values = custom_values_by_project_ids(projects_arrray, ProjectCustomField.all)
    refute_nil values
    assert_kind_of Hash, values
    expect(values.size).to eq 6
    assert_equal({3=>"Stable"}, values[Project.first.id])
  end
end
