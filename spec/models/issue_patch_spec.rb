require "spec_helper"

require 'redmine_multiprojects_issue/issue_patch.rb'

# Generates an unsaved Issue
def Issue.generate(attributes={})
  issue = Issue.new(attributes)
  issue.project ||= Project.find(1)
  issue.tracker ||= issue.project.trackers.first
  issue.subject = 'Generated' if issue.subject.blank?
  issue.author ||= User.find(2)
  yield issue if block_given?
  issue
end

# Generates a saved Issue
def Issue.generate!(attributes={}, &block)
  issue = Issue.generate(attributes, &block)
  issue.save!
  issue
end

describe "IssueMultiprojectsPatch" do

  fixtures :projects, :enabled_modules, :users, :members,
           :member_roles, :roles, :trackers, :issue_statuses,
           :issue_categories, :enumerations, :issues,
           :watchers, :custom_fields, :custom_values, :versions,
           :queries,
           :projects_trackers,
           :custom_fields_trackers

  before do
    multiproject_issue = Issue.find(4) # project_id = 2
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!
    new_member = Member.new(:project_id => 5, :user_id => 4)
    new_member.roles = [Role.find(2)]
    new_member.save!
  end

  it "should visible patch when project is public" do
    issue = Issue.find(1) # project_id = 1
    assert issue.visible?(User.anonymous)
    assert issue.visible?(User.find(8))
  end

  it "should visible patch when project is private" do
    issue = Issue.generate!(:is_private => false, project: Project.find(2))
    assert !issue.visible?(User.anonymous), ": issue (#{issue.inspect}) should not be visible when user is not set and project is private"
    assert issue.visible?(User.find(8)) # member of project 2
    assert !issue.visible?(User.find(3)) # not a member
  end

  it "should visible patch when issue has several projects" do
    multiproject_issue = Issue.find(4) # project_id = 2
    assert multiproject_issue.projects.size > 1
    assert !multiproject_issue.visible?(User.anonymous)
    assert multiproject_issue.visible?(User.find(8)) # member of project 2 and 5
    assert multiproject_issue.visible?(User.find(1)) # member of project 5 only
    assert multiproject_issue.visible?(User.find(4)) # member of project 5 only, not admin
    assert !multiproject_issue.visible?(User.find(3)) # not a member
  end

  it "should anonymous should not see private issues with issues visibility set to default" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  it "should anonymous should not see private issues with issues visibility set to own" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  it "should anonymous should not see private multiproject issues with issues visibility set to default" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  it "should anonymous should not see private multiproject issues with issues visibility set to own" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  it "should anonymous should not see private projects issues with issues visibility set to all" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'all')
    issue = Issue.generate!(:is_private => false, project: Project.find(2), projects: [Project.find(2),Project.find(5)]) # multiprojects issue
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  it "should core visible method when project is public" do
    issue = Issue.find(1) # project_id = 1
    assert issue.visible_without_multiproject_issues?(User.anonymous)
    assert issue.visible_without_multiproject_issues?(User.find(8))
  end

  it "should core visible method when project is private" do
    issue = Issue.generate!(:is_private => false, project: Project.find(2))
    assert !issue.visible_without_multiproject_issues?(User.anonymous), ": issue (#{issue.inspect}) should not be visible when user is not set and project is private"
    assert issue.visible_without_multiproject_issues?(User.find(8)) # member of project 2
    assert !issue.visible_without_multiproject_issues?(User.find(3)) # not a member
  end

  it "should core visible method when issue has several projects" do
    multiprojects_issue = Issue.find(4) # project_id = 2
    assert multiprojects_issue.projects.size > 1
    assert !multiprojects_issue.visible_without_multiproject_issues?(User.anonymous)
    assert multiprojects_issue.visible_without_multiproject_issues?(User.find(8)) # member of project 2 and 5
    assert multiprojects_issue.visible_without_multiproject_issues?(User.find(1)) # member of project 5 only, but admin
    assert !multiprojects_issue.visible_without_multiproject_issues?(User.find(4)) # member of project 5 only, not admin
    assert !multiprojects_issue.visible_without_multiproject_issues?(User.find(3)) # not a member
  end

  it "should core visible method anonymous should not see private issues with issues visibility set to default" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  it "should core visible method anonymous should not see private issues with issues visibility set to own" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  it "should core visible method anonymous should not see private multiproject issues with issues visibility set to default" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  it "should core visible method anonymous should not see private multiproject issues with issues visibility set to own" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  it "should core visible method anonymous should not see private projects issues with issues visibility set to all" do
    assert Role.anonymous.update_attribute(:issues_visibility, 'all')
    issue = Issue.generate!(:is_private => false, project: Project.find(2), projects: [Project.find(2),Project.find(5)]) # multiprojects issue
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  it "should other project visible method when issue has no other project" do
    issue = Issue.find(1)
    assert !issue.other_project_visible?(User.anonymous)
    assert !issue.other_project_visible?(User.find(8))
  end

  it "should other project visible method when issue has several projects" do
    multiprojects_issue = Issue.find(4) # project_id = 2
    assert multiprojects_issue.projects.size > 1
    assert !multiprojects_issue.other_project_visible?(User.anonymous)
    assert multiprojects_issue.other_project_visible?(User.find(8)) # member of project 2 and 5
    assert multiprojects_issue.other_project_visible?(User.find(1)) # member of project 5 only, but admin
    assert multiprojects_issue.other_project_visible?(User.find(4)) # member of project 5 only, not admin
    assert !multiprojects_issue.other_project_visible?(User.find(3)) # not a member
  end

  it "should other project visible method user should not see private issues with issues visibility set to default" do
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  it "should other project visible method user should not see private issues with issues visibility set to own" do
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  it "should other project visible method user should not see private multiproject issues with issues visibility set to default" do
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    refute_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  it "should other project visible method member should not see private multiproject issues with issues visibility set to own" do
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    refute_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  it "should other project visible method member should see private projects issues with issues visibility set to all" do
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'all')
    issue = Issue.generate!(:is_private => false, project: Project.find(2), projects: [Project.find(2),Project.find(5)]) # multiprojects issue
    refute_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert issue.other_project_visible?(User.find(8))
  end

  it "should visible condition when there are authorized projects" do
    Issue.visible_condition(User.find(4)) # should include issues_projects table name.should include("issues_projects")
  end

  it "should visible condition when there are no authorized projects" do
    expect("issues_projects").to_not include Issue.visible_condition(User.anonymous) # should not include issues_projects table name
  end

  it "should core visible condition when there are no authorized projects" do
    expect("issues_projects").to_not include Issue.visible_condition_without_multiproject_issues(User.find(4)) # should not include issues_projects table name
  end

  it "should notified users from other projects" do
    issue = Issue.find(4)
    notified_users_from_other_projects = issue.notified_users_from_other_projects
    refute_nil notified_users_from_other_projects
    expect(notified_users_from_other_projects).to_not include User.anonymous
    expect(notified_users_from_other_projects).to include User.find(1) # member of project 5 only, but admin
    expect(notified_users_from_other_projects).to_not include User.find(3) # not a member
    expect(notified_users_from_other_projects).to include User.find(4) # member of project 5 only, not admin
    expect(notified_users_from_other_projects).to_not include User.find(8) # member of project 2 and 5 but mail_notification = only_my_events
  end

  it "should notified users from main project" do
    issue = Issue.find(4)
    notified_users_from_main_project = issue.notified_users_without_multiproject_issues
    refute_nil notified_users_from_main_project
    expect(notified_users_from_main_project).to_not include User.anonymous
    expect(notified_users_from_main_project).to_not include User.find(1) # member of project 5 only, but admin
    expect(notified_users_from_main_project).to include User.find(2) # member of main project 2
    expect(notified_users_from_main_project).to_not include User.find(3) # not a member
    expect(notified_users_from_main_project).to_not include User.find(4) # member of project 5 only, not admin
    expect(notified_users_from_main_project).to_not include User.find(8) # member of project 2 and 5 but mail_notification = only_my_events
  end

  it "should notified users should include previous assignee" do
    user = User.find(3)
    user.members.update_all ["mail_notification = ?", false]
    user.update_attribute :mail_notification, 'only_assigned'

    issue = Issue.find(2)
    issue.assigned_to = nil
    expect(issue.notified_users).to include user
    issue.save!
    assert !issue.notified_users.include?(user)
  end

  it "should notified users should not include users that cannot view the issue" do
    issue = Issue.find(12)
    assert issue.notified_users.include?(issue.author)
    # copy the issue to a private project
    copy  = issue.copy(:author_id => issue.author.id, :project_id => 5, :tracker_id => 2)
    # author is not a member of project anymore
    assert !copy.notified_users.include?(copy.author)
  end

  it "should editable allows member of secondary project to edit issue" do
    issue = Issue.find(4)
    issue.update_attribute(:answers_on_secondary_projects, true)
    user = User.find(4) #member of project(5)
    assert !user.member_of?(issue.project) #but not member of main project
    #go
    assert issue.editable?(user), "user(4) should be able to edit issue(4) as it is editable on secondary projects"
    assert issue.safe_attribute_names(user).include?("notes")
  end

  it "should editable doesnt allow member of secondary project to edit issue if forbidden" do
    issue = Issue.find(4)
    issue.update_attribute(:answers_on_secondary_projects, false)
    user = User.find(4) #member of project(5)
    assert !user.member_of?(issue.project) #but not member of main project
    #go
    assert !issue.editable?(user), "user(4) should be able to edit issue(4) as it is editable on secondary projects"
    assert !issue.safe_attribute_names(user).include?("notes")
  end
end
