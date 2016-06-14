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
    # 2.3.3 is ok
    # 2.5.1 and 2.5.2 are ok
    # 2.6.0 is ok
    # 3.0.3 and 3.1.0 are ok
    # 3.1.1 and 3.2.x are ok
    assert_checksum %w(7265e9dcb488ac8ea89ed7c3c92c8c88
                       31b05314384ac3bbe273ae9a0b0f7e24
                       f93d75a3bb8f60360e957d9335c15f43
                       2ebfdef98d98062124c77cc12f61519f
                       5c85983c6b8ddb52fe4656d8e5d2471c,
                       a5a2fa1156016e4380e63d9f75c3bd75,
                       157f0a0c68e90e302ae565ac3cdb2ed7,
                       087c5c94f641196d8c6511a02fb630f6,
                       fd68745c6510526da2b8a9f5bd90bf50), "app/models/issue.rb"
  end

  # tests have been added to the issue_helper_patch_test file, no need to check the checksum
  #def test_core_issues_helper_checksum
    # "show_detail" method is overridden
    # assert_checksum %w(9ef285e8ecc7986993cd31d8bd84b156), "app/helpers/issues_helper.rb"
  #end

  it "should core query model checksum" do
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3, 2.5.1, 2.6.0, 3.0.3, 3.1.0, 3.2.0 are ok
    assert_checksum %w(4c224b8cf3777fe2708139cfa77684eb
                       01fe00cf132446c39f0485148ddaf8f7
                       cb76a735b8d9304cadf1fc40e641dc7e
                       5db60e7361522d102722fbcff95494e5
                       63238edafc1bf5c83ec3da125eb5b776
                       7984916a8552543a898767f977efaa26
                       4df7fc5643d9d7ed3cd1b13ac3d040ba), "app/models/query.rb"
  end

  it "should core issue query model checksum" do
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 2.3.3, 2.5.1, 2.6.0, 3.0.3, 3.1.0 and 3.1.1 are ok
    assert_checksum %w(640fbc448f8d90093d05685aa4292893
                       6c1ba80a5f4e22680ecb946a6509599a
                       683cedbb78c368325997a6fe11d27d5c
                       53ab195fad836aae2ad7f6aeb273ca17
                       6a6600f344e389682a8d51a881e089b7
                       949d5cdd375d4247a061fb004d90a81f
                       404e39ee0c76ac64eb5eb429d2be99a7
                       db85b87f2b4a770ee5b4657ec7e31e1a), "app/models/issue_query.rb"
  end

  it "should core edit and new form js checksum" do
    # "new.js.erb" and "edit.js.erb" are completely overridden
    # and should be reviewed if these tests breaks
    # 3.0.3 and 3.2.0 are ok
    assert_checksum %w(c6f78d63d0c029a215c0c577ecc42f7f 4ee0634707b28d83f3e41449c6d1cd21), "app/views/issues/new.js.erb"
    assert_checksum %w(0a92d0609b883d43daf5e825bc08cb01 2ca65dcbd64f6047fe81b4d195ce5b21), "app/views/issues/edit.js.erb"
  end

end
