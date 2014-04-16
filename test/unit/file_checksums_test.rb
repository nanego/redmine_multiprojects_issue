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
    # 2.5.1 is ok
    assert_checksum %w(7265e9dcb488ac8ea89ed7c3c92c8c88 31b05314384ac3bbe273ae9a0b0f7e24), "app/models/issue.rb"
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
    # 2.5.1 is ok
    assert_checksum %w(4c224b8cf3777fe2708139cfa77684eb 01fe00cf132446c39f0485148ddaf8f7), "app/models/query.rb"
  end

  def test_core_issue_query_model_checksum
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3 is ok
    # 2.5.1 is ok
    assert_checksum %w(640fbc448f8d90093d05685aa4292893 6c1ba80a5f4e22680ecb946a6509599a), "app/models/issue_query.rb"
  end

end
