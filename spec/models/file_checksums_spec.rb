require "spec_helper"

describe "FileChecksums" do

  def assert_checksum(expected, filename)
    filepath = Rails.root.join(filename)
    checksum = Digest::MD5.hexdigest(File.read(filepath))
    assert checksum.in?(Array(expected)), "Bad checksum for file: #{filename}, local version should be reviewed: checksum=#{checksum}, expected=#{Array(expected).join(" or ")}"
  end
  it "should core issue model checksum" do
    # "notified_users", "visible_condition" and "visible?" methods are overridden
    # and should be reviewed if this test breaks
    # 4.0.0 is ok
    assert_checksum %w(71289d390f3afbd70f0e284382875e5d), "app/models/issue.rb"
  end

  # tests have been added to the issue_helper_patch_test file, no need to check the checksum
  #def test_core_issues_helper_checksum
    # "show_detail" method is overridden
    # assert_checksum %w(9ef285e8ecc7986993cd31d8bd84b156), "app/helpers/issues_helper.rb"
  #end

  it "should core query model checksum" do
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # 4.0.0 is ok
    assert_checksum %w(1b2c9e04706dbaff4130a7fb6e36342e), "app/models/query.rb"
  end

  it "should core issue query model checksum" do
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 4.0.0 is ok
    assert_checksum %w(5eb12a32cb1af4fa2ec4d01c37923496), "app/models/issue_query.rb"
  end

  it "should core edit and new form js checksum" do
    # "new.js.erb" and "edit.js.erb" are completely overridden
    # and should be reviewed if these tests breaks
    # 4.0.0 is ok
    assert_checksum %w(2567d0882238652fc51e905d6ebe4b9c), "app/views/issues/new.js.erb"
    assert_checksum %w(0a92d0609b883d43daf5e825bc08cb01), "app/views/issues/edit.js.erb"
  end

end
