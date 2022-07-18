require "rails_helper"

describe AttachmentsController do
  render_views

  fixtures :users, :projects, :roles, :members, :member_roles,
           :enabled_modules, :issues, :trackers, :attachments,
           :versions, :wiki_pages, :wikis, :documents

  before do
    multiproject_issue = Issue.find(4) # project_id = 2
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!
    new_member = Member.new(:project_id => 5, :user_id => 4)
    new_member.roles = [Role.find(2)]
    new_member.save!
  end

  it "should show text file utf 8" do

    # test setup
    multiproject_issue = Issue.find(4) # project_id = 2
    assert multiproject_issue.projects.size > 1
    assert !multiproject_issue.visible?(User.anonymous)
    assert multiproject_issue.visible?(User.find(8)) # member of project 2 and 5
    assert multiproject_issue.visible?(User.find(1)) # member of project 5 only
    assert multiproject_issue.visible?(User.find(4)) # member of project 5 only, not admin
    assert !multiproject_issue.visible?(User.find(3)) # not a member

    @request.session[:user_id] = 4 # member of project 5 only, not admin

    set_tmp_attachments_directory
    a = Attachment.new(:container => multiproject_issue,
                       :file => uploaded_test_file('japanese-utf-8.txt', "text/plain"),
                       :author => User.find(1))
    assert a.save
    expect(a.filename).to eq 'japanese-utf-8.txt'

    str_japanese = "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e".force_encoding('UTF-8')

    get :show, params: { :id => a.id }
    expect(response).to be_successful
    assert_template 'file'
    expect(@response.media_type).to eq 'text/html'

    assert_select 'tr#L1' do
      if Redmine::VERSION::MAJOR >= 5
        assert_select 'th.line-num a[data-txt=?]', '1'
      else
        assert_select 'th.line-num', :text => '1'
      end
      assert_select 'td', :text => /#{str_japanese}/
    end
  end

  # Use a temporary directory for attachment related tests
  def set_tmp_attachments_directory
    Dir.mkdir "#{Rails.root}/tmp/test" unless File.directory?("#{Rails.root}/tmp/test")
    unless File.directory?("#{Rails.root}/tmp/test/attachments")
      Dir.mkdir "#{Rails.root}/tmp/test/attachments"
    end
    Attachment.storage_path = "#{Rails.root}/tmp/test/attachments"
  end

end
