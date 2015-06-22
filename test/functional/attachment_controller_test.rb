require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/acts_as_attachable_patch'

class AttachmentsControllerTest < ActionController::TestCase

  fixtures :users, :projects, :roles, :members, :member_roles,
           :enabled_modules, :issues, :trackers, :attachments,
           :versions, :wiki_pages, :wikis, :documents

  def setup # create multiproject issue
    multiproject_issue = Issue.find(4) # project_id = 2
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!
    new_member = Member.new(:project_id => 5, :user_id => 4)
    new_member.roles = [Role.find(2)]
    new_member.save!
  end

  def test_show_text_file_utf_8

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
                       :file => uploaded_test_file("japanese-utf-8.txt", "text/plain"),
                       :author => User.find(1))
    assert a.save
    assert_equal 'japanese-utf-8.txt', a.filename

    str_japanese = "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e".force_encoding('UTF-8')

    get :show, :id => a.id
    assert_response :success
    assert_template 'file'
    assert_equal 'text/html', @response.content_type
    assert_select 'tr#L1' do
      assert_select 'th.line-num', :text => '1'
      assert_select 'td', :text => /#{str_japanese}/
    end
  end

end
