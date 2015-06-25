require "spec_helper"

describe "MultiprojectsIssueHelper" do
  include MultiprojectsIssueHelper

  it "should custom_values_by_projects" do
    values = custom_values_by_projects(Project.all, CustomField.all)
    refute_nil values
    assert_kind_of Hash, values
    expect(values.size).to eq 6
    assert_equal({3=>"Stable"}, values[Project.first.id])
  end
end
