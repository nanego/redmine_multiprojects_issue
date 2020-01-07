require "spec_helper"
require 'redmine_multiprojects_issue/issues_controller_patch.rb'
require 'redmine_multiprojects_issue/issue_patch.rb'

#taken from core
def log_user(login, password)
  User.anonymous
  get "/login"
  assert_equal nil, session[:user_id]
  assert_response :success
  assert_template "account/login"
  post "/login", params: {:username => login, :password => password}
  assert_equal login, User.find(session[:user_id]).login
end

describe "Issues" do

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  before(:each) do
    Role.find(1).add_permission!(:link_other_projects_to_issue) # Role for User:jsmith on Project:1
  end

  # create an issue with multiple projects
  it "should create issue with multiple projects" do
    log_user('jsmith', 'jsmith')
    get '/projects/1/issues/new', params: {:tracker_id => '1'}
    expect(response).to be_successful
    assert_template 'issues/new'
    assert_select "p#projects_form", :count => 1

    post '/projects/1/issues', params: {:tracker_id => "1",
                                        :issue => {:start_date => "2006-12-26",
                                                   :priority_id => "4",
                                                   :subject => "new multiproject test issue",
                                                   :category_id => "",
                                                   :description => "new issue",
                                                   :done_ratio => "0",
                                                   :due_date => "",
                                                   :assigned_to_id => "",
                                                   :project_ids => [2, 3, 4]
                                        },
                                        :custom_fields => {'2' => 'Value for field 2'}}

    # find created issue
    issue = Issue.find_by_subject("new multiproject test issue")
    assert_kind_of Issue, issue

    # check redirection
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => issue)
    follow_redirect!
    expect(assigns(:issue)).to eq issue

    # check issue attributes
    expect(issue.author.login).to eq 'jsmith'
    expect(issue.project.id).to eq 1
    expect(issue.projects.collect(&:id)).to eq [2, 3, 4]
  end

  it "should not be allowed to create issue with multiple projects" do
    Role.find(1).remove_permission!(:link_other_projects_to_issue) # Role for User:jsmith on Project:1
    log_user('jsmith', 'jsmith')
    get '/projects/1/issues/new', params: {:tracker_id => '1'}
    expect(response).to be_successful
    assert_template 'issues/new'
    assert_select "p#projects_form", :count => 0
  end

  # update an issue and set several projects
  it "should update projects" do
    log_user('jsmith', 'jsmith')
    get '/issues/1/edit'
    expect(response).to be_successful
    assert_template 'issues/edit'
    assert_select "p#projects_form", :count => 1

    put '/issues/1', params: {:issue => {:project_ids => [2, 3, 4]}, :project_id => 1}

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => issue)
    follow_redirect!
    expect(assigns(:issue)).to eq issue

    # check issue attributes
    expect(issue.author.login).to eq 'jsmith'
    expect(issue.project.id).to eq 1
    expect(issue.projects.collect(&:id)).to eq [2, 3, 4]
  end

  # remove the unique other project
  it "should remove unique other project" do
    log_user('jsmith', 'jsmith')
    get '/issues/1/edit'
    expect(response).to be_successful
    assert_template 'issues/edit'
    assert_select "p#projects_form", :count => 1

    put '/issues/1', params: {:issue => {:project_ids => [2]}, :project_id => 1}

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => issue)
    follow_redirect!
    expect(assigns(:issue)).to eq issue

    # check issue attributes
    expect(issue.author.login).to eq 'jsmith'
    expect(issue.project.id).to eq 1
    expect(issue.projects.collect(&:id)).to eq [2]

    ### Remove other project
    put '/issues/1', params: {:issue => {:project_ids => [""]}, :project_id => 1}

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => issue)
    follow_redirect!
    expect(assigns(:issue)).to eq issue

    # check issue attributes
    expect(issue.author.login).to eq 'jsmith'
    expect(issue.project.id).to eq 1
    expect(issue.projects.collect(&:id)).to eq []
  end

  it "should show issue with several projects" do
    multiproject_issue = Issue.find(4) # project_id = 2
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!

    log_user('jsmith', 'jsmith')
    get '/issues/4'
    expect(response).to be_successful
    assert_template 'issues/show'
    refute_nil assigns(:issue).projects
    assert assigns(:issue).projects.present?
    assert_select 'div#current_projects_list', :count => 1
  end

  it "should show issue with no other projects" do
    monoproject_issue = Issue.find(4) # project_id = 2
    monoproject_issue.projects = [monoproject_issue.project]
    monoproject_issue.save!

    log_user('jsmith', 'jsmith')
    get '/issues/4'
    expect(response).to be_successful
    assert_template 'issues/show'
    refute_nil assigns[:issue]
    expect(assigns(:issue).projects).to eq [Project.find(2)]
    assert_select 'div#current_projects_list', :count => 0
  end

end
