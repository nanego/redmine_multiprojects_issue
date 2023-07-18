require "spec_helper"

describe "MultiprojectsIssueHelper" do
  include MultiprojectsIssueHelper

  describe "custom_values_by_project_ids method" do
    it "returns a hash of custom-field values by project" do
      project_ids = Project.all.map(&:id)
      projects_array = Project.find(project_ids).pluck(:id, :name, :status, :lft, :rgt).to_a
      values = custom_values_by_project_ids(projects_array, ProjectCustomField.all)
      refute_nil values
      assert_kind_of Hash, values
      expect(values.size).to eq 6
      assert_equal({ 3 => "Stable" }, values[Project.first.id])
    end
  end

end
