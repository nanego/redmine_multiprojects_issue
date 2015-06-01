require File.expand_path('../../test_helper', __FILE__)

class MultiprojectsIssueHelperTest < ActiveSupport::TestCase
  include MultiprojectsIssueHelper

  test 'custom_values_by_projects' do
    values = custom_values_by_projects(Project.all, CustomField.all)
    refute_nil values
    assert_kind_of Hash, values
    assert_equal 6, values.size
    assert_equal({3=>"Stable"}, values[Project.first.id])
  end
end
