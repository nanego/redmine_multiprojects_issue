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
    assert_checksum %w(32325432e247c968e3926bea6898f9d8), "app/models/issue.rb"
  end

  # tests have been added to the issue_helper_patch_test file, no need to check the checksum
  #def test_core_issues_helper_checksum
    # "show_detail" method is overridden
    # assert_checksum %w(9ef285e8ecc7986993cd31d8bd84b156), "app/helpers/issues_helper.rb"
  #end

  def test_core_query_model_checksum
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3 is ok
    assert_checksum %w(4c224b8cf3777fe2708139cfa77684eb), "app/models/query.rb"
  end

  def test_core_issue_query_model_checksum
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3 is ok
    assert_checksum %w(aa6432647c5c8719b6405c9799462a51), "app/models/issue_query.rb"
  end

end
