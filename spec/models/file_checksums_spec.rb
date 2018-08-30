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
    # 3.4.x are ok
    assert_checksum %w(1ea907d32e75e3b26ca00cd474eb4897), "app/models/issue.rb"
  end

  # tests have been added to the issue_helper_patch_test file, no need to check the checksum
  #def test_core_issues_helper_checksum
    # "show_detail" method is overridden
    # assert_checksum %w(9ef285e8ecc7986993cd31d8bd84b156), "app/helpers/issues_helper.rb"
  #end

  it "should core query model checksum" do
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3, 2.5.1, 2.6.0, 3.0.3, 3.1.0, 3.2.0, 3.3.x, 3.4.x are ok
    assert_checksum %w(4c224b8cf3777fe2708139cfa77684eb
                       01fe00cf132446c39f0485148ddaf8f7
                       cb76a735b8d9304cadf1fc40e641dc7e
                       5db60e7361522d102722fbcff95494e5
                       63238edafc1bf5c83ec3da125eb5b776
                       7984916a8552543a898767f977efaa26
                       4df7fc5643d9d7ed3cd1b13ac3d040ba
                       4578911937e52016a86fdc5b6e73b9ee
                       9267617c77561572f7bba862d115cddb
                       fc595145ab400cac5e333f880d29c1ba
                       a1c2519e9bae097b5659adf9338ba7d0
                       a266d0434f7dfdde72a9dbf7bb16b5fa), "app/models/query.rb"
  end

  it "should core issue query model checksum" do
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 3.4.x are ok
    assert_checksum %w(62f1483ba76fbbb93cd1f3ea032bd523), "app/models/issue_query.rb"
  end

  it "should core edit and new form js checksum" do
    # "new.js.erb" and "edit.js.erb" are completely overridden
    # and should be reviewed if these tests breaks
    # 3.4.x is ok
    assert_checksum %w(34e85ae56e20632f4d87b1bb19acee12), "app/views/issues/new.js.erb"
    assert_checksum %w(0a92d0609b883d43daf5e825bc08cb01), "app/views/issues/edit.js.erb"
  end

end
