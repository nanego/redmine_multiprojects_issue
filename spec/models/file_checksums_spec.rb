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
    # 6.1.5, 7.0.2 & master are ok
    assert_checksum %w(bffd93131f594e95bc456bfd20e16451 803824e202d35bf3a8da35e3e01eaa33 1aef43c620f49b15ccc6344bdde0d17c), "app/models/issue.rb"
  end

  it "should core query model checksum" do
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # "value_object" methods are completely overridden, for performance reasons
    # and should be reviewed if these tests break
    # 6.1.5, 7.0.2 & master are ok
    assert_checksum %w(37abce7cdc7110240c36af23f6785d05 11cbfe6f95bd72aee2a8dc9cd22741c2 59f46580df399299165557ccd33e3b8d), "app/models/query.rb"
  end

  it "should core issue query model checksum" do
    # "versions" and "sql_for_any_searchable_field" methods are completely overridden
    # and should be reviewed & adapted if this test breaks
    # 6.1.5, 7.0.2 & master are ok
    assert_checksum %w(d2722ad2a20e2d5be862e239e96e501b b1c04932303907c2993bf35e7f089f00 2121bd2018b68203864da8963dc83472), "app/models/issue_query.rb"
  end

  it "should core edit and new form js checksum" do
    # "new.js.erb" and "edit.js.erb" are completely overridden
    # and should be reviewed if these tests breaks
    # 6.1.5, 7.0.2 & master are ok
    assert_checksum %w(01e29fb257e5700dff94051420a4440a), "app/views/issues/new.js.erb"
    assert_checksum %w(76796d4f9c44b39a842c4f616c84d6c5), "app/views/issues/edit.js.erb"
  end

  it "should check acts_as_activity_provider" do
    # "acts_as_activity_provider.rb" is completely overridden
    # and should be reviewed if these tests breaks
    # 6.1.5, 7.0.2 & master are ok
    assert_checksum %w(83d04d01b335576ee26883e007f4d0bc), "lib/plugins/acts_as_activity_provider/lib/acts_as_activity_provider.rb"
  end

  it "checks issue_custom_field model changes" do
    # "visibility_by_project_condition" method is completely overridden, for performance reasons
    # and should be reviewed if these tests breaks
    # 6.1.5, 7.0.2 & master are ok
    assert_checksum %w(cd3eed0a50478ba316502f37e51cb43d ba3cec792f417c8acaa643813d09c10a), "app/models/issue_custom_field.rb"
  end

end
