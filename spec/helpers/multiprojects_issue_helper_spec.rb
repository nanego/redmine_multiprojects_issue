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

  describe "enumerations_values_by_custom_fields method" do
    before do
      cf = ProjectCustomField.
        create!(
          :name => "CustomField-with-enumeration",
          :field_format => 'enumeration'
        )
      cf.enumerations << @valueb = CustomFieldEnumeration.new(:name => "Value B", :position => 1)
      cf.enumerations << @valuea = CustomFieldEnumeration.new(:name => "Value A", :position => 2)
    end

    it "returns a hash of enumerations_values_by_custom_fields" do
      custom_fields = CustomField.where(field_format: 'enumeration')
      hash = enumerations_values_by_custom_fields(custom_fields)
      expect(hash.size).to eq 1
      expect(hash.first.size).to eq 2
      expect(hash[custom_fields.first.id]).to eq({ @valueb.id => "Value B", @valuea.id => "Value A" })
    end
  end

end
