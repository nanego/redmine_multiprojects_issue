require File.dirname(__FILE__) + '/../test_helper'

class FileChecksumsTest < ActiveSupport::TestCase

  def assert_checksum(expected, filename)
    filepath = Rails.root.join(filename)
    checksum = Digest::MD5.hexdigest(File.read(filepath))
    assert checksum.in?(Array(expected)), "Bad checksum for file: #{filename}, local version should be reviewed: checksum=#{checksum}, expected=#{Array(expected).join(" or ")}"
  end

  def test_core_issue_model_checksum
    # "notified_users", "visible_condition" and "visible?" methods are overridden
    # and should be reviewed if this test breaks
    # 2.3.3 is ok
    # 2.5.1 and 2.5.2 are ok
    # 2.6.0 is ok
    assert_checksum %w(7265e9dcb488ac8ea89ed7c3c92c8c88 31b05314384ac3bbe273ae9a0b0f7e24 f93d75a3bb8f60360e957d9335c15f43 2ebfdef98d98062124c77cc12f61519f), "app/models/issue.rb"
  end

  # tests have been added to the issue_helper_patch_test file, no need to check the checksum
  #def test_core_issues_helper_checksum
    # "show_detail" method is overridden
    # assert_checksum %w(9ef285e8ecc7986993cd31d8bd84b156), "app/helpers/issues_helper.rb"
  #end

  def test_core_query_model_checksum
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3, 2.5.1 and 2.6.0 are ok
    assert_checksum %w(4c224b8cf3777fe2708139cfa77684eb 01fe00cf132446c39f0485148ddaf8f7 cb76a735b8d9304cadf1fc40e641dc7e), "app/models/query.rb"
  end

  def test_core_issue_query_model_checksum
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3, 2.5.1 and 2.6.0 are ok
    assert_checksum %w(640fbc448f8d90093d05685aa4292893 6c1ba80a5f4e22680ecb946a6509599a 683cedbb78c368325997a6fe11d27d5c), "app/models/issue_query.rb"
  end

  def test_core_update_form_js_checksum
    # "update_form.js.erb" is completely overridden
    # and should be reviewed if this test breaks
    # 2.3.3 is ok
    # 2.5.1 is ok
    assert_checksum %w(9f56556a894c788d7bf2b00ed5e9023e 0a92d0609b883d43daf5e825bc08cb01), "app/views/issues/update_form.js.erb"
  end

end
