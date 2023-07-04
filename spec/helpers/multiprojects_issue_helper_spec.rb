require "spec_helper"

describe "MultiprojectsIssueHelper" do
  include MultiprojectsIssueHelper

  it "should custom_values_by_projects" do
    values = custom_values_by_projects(Project.all, ProjectCustomField.all)
    refute_nil values
    assert_kind_of Hash, values
    expect(values.size).to eq 6
    assert_equal({3=>"Stable"}, values[Project.first.id])
  end

  it "should custom_values_by_attributes_projects" do
    project_ids = Project.all.map(&:id)
    projects_arrray = Project.find(project_ids).pluck(:id, :name, :status, :lft, :rgt).to_a
    values = custom_values_by_attributes_projects(projects_arrray, ProjectCustomField.all)
    refute_nil values
    assert_kind_of Hash, values
    expect(values.size).to eq 6
    assert_equal({3=>"Stable"}, values[Project.first.id])
  end
end
