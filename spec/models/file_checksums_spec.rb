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
    # 5.0.5, 5.1.4 & 6.0.1 are ok
    assert_checksum %w(76ac12461d069c7d2aa53126b8219647 0d6adafb489d691bceb91a1afc784b6e 050e47f1677589a3a45fe54ddef0be5b 80e3cd16f786b0a1d61dc0a6a7355b41 83351a1bf3463eb7832dcfff7aa4536c), "app/models/issue.rb"
  end

  it "should core query model checksum" do
    # "project_statement" method is overridden
    # and should be reviewed if this test breaks
    # "value_object" methods are completely overridden, for performance reasons
    # and should be reviewed if these tests break
    # 6.0.5, 5.1.4, 5.0.5 & 4.2.10 are ok
    assert_checksum %w(37abce7cdc7110240c36af23f6785d05 61ad417ea93187ad21be61667cdcacdd 583977d5b4b9edb245ca5246a1550c98 719ec73a836c058f45eff8fad3487444), "app/models/query.rb"
  end

  it "should core issue query model checksum" do
    # "versions" and "sql_for_any_searchable_field" methods are completely overridden
    # and should be reviewed & adapted if this test breaks
    # 6.0.1, 5.1.4 & 4.2.10 are ok
    assert_checksum %w(d2722ad2a20e2d5be862e239e96e501b 18da20450d225893e06c4e2e8fa28444 13ac2c6520f023c95a4e925d331dce4d), "app/models/issue_query.rb"
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
    # 6.0 & 5.0 & 4.2 are ok
    assert_checksum %w(83d04d01b335576ee26883e007f4d0bc d894d66234154c7c99eb0572e3eda713 f2eb81d694b0965968d5870a6ba7585a), "lib/plugins/acts_as_activity_provider/lib/acts_as_activity_provider.rb"
  end

  it "checks issue_custom_field model changes" do
    # "visibility_by_project_condition" method is completely overridden, for performance reasons
    # and should be reviewed if these tests breaks
    # 6.0, 5.0 & 4.2.10 are ok
    assert_checksum %w(cd3eed0a50478ba316502f37e51cb43d 20207f79f8b518e982a55d983799d959 0d482e3fa86ff083a1847d0c193aabbd), "app/models/issue_custom_field.rb"
  end

end
