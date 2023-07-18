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
    # 4.2.10 and 5.0 are ok
    assert_checksum %w(0d6adafb489d691bceb91a1afc784b6e a1f8ffdc9ec1124468d45780731a94a9), "app/models/issue.rb"
  end

  it "should core query model checksum" do
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # "value_object" methods are completely overridden, for performance reasons
    # and should be reviewed if these tests breaks
    # 5.0 & 4.2.10 are ok
    assert_checksum %w(5f5afc5903e5d9ff99847c4efd9d539c 583977d5b4b9edb245ca5246a1550c98), "app/models/query.rb"
  end

  it "should core issue query model checksum" do
    # "versions" method is overridden
    # and should be reviewed if this test breaks
    # 5.0 & 4.2.10 are ok
    assert_checksum %w(65a5f4f2f9e60ffcdc48af9be7106d5f 13ac2c6520f023c95a4e925d331dce4d), "app/models/issue_query.rb"
  end

  it "should core edit and new form js checksum" do
    # "new.js.erb" and "edit.js.erb" are completely overridden
    # and should be reviewed if these tests breaks
    # 5.0 & 4.2 are ok
    assert_checksum %w(76796d4f9c44b39a842c4f616c84d6c5 1fd7f7770d15713675b475d07dd2d364), "app/views/issues/new.js.erb"
    assert_checksum %w(76796d4f9c44b39a842c4f616c84d6c5 0a92d0609b883d43daf5e825bc08cb01), "app/views/issues/edit.js.erb"
  end

  it "should check acts_as_activity_provider" do
    # "acts_as_activity_provider.rb" is completely overridden
    # and should be reviewed if these tests breaks
    # 5.0 & 4.2 are ok
    assert_checksum %w(96b4b7b1cc44fdee7dcedb797c8c861a f2eb81d694b0965968d5870a6ba7585a), "lib/plugins/acts_as_activity_provider/lib/acts_as_activity_provider.rb"
  end

  it "checks issue_custom_field model changes" do
    # "visibility_by_project_condition" method is completely overridden, for performance reasons
    # and should be reviewed if these tests breaks
    # 5.0 && 4.2.10 are ok
    assert_checksum %w(9b735f4f3783e242169fd80fd53a443e 0d482e3fa86ff083a1847d0c193aabbd), "app/models/issue_custom_field.rb"
  end

end
