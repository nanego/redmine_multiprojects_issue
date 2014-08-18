require File.expand_path('../../test_helper', __FILE__)

require 'redmine_multiprojects_issue/issue_patch.rb'

class IssueMultiprojectsPatchTest < ActiveSupport::TestCase

  fixtures :projects, :enabled_modules, :users, :members,
           :member_roles, :roles, :trackers, :issue_statuses,
           :issue_categories, :enumerations, :issues,
           :watchers, :custom_fields, :custom_values, :versions,
           :queries,
           :projects_trackers,
           :custom_fields_trackers

  def setup # create multiproject issue
    multiproject_issue = Issue.find(4) # project_id = 2
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!
    new_member = Member.new(:project_id => 5, :user_id => 4)
    new_member.roles = [Role.find(2)]
    new_member.save!
  end

  def test_visible_patch_when_project_is_public
    issue = Issue.find(1) # project_id = 1
    assert issue.visible?(User.anonymous)
    assert issue.visible?(User.find(8))
  end

  def test_visible_patch_when_project_is_private
    issue = Issue.generate!(:is_private => false, project: Project.find(2))
    assert !issue.visible?(User.anonymous), ": issue (#{issue.inspect}) should not be visible when user is not set and project is private"
    assert issue.visible?(User.find(8)) # member of project 2
    assert !issue.visible?(User.find(3)) # not a member
  end

  def test_visible_patch_when_issue_has_several_projects
    multiproject_issue = Issue.find(4) # project_id = 2
    assert multiproject_issue.projects.size > 1
    assert !multiproject_issue.visible?(User.anonymous)
    assert multiproject_issue.visible?(User.find(8)) # member of project 2 and 5
    assert multiproject_issue.visible?(User.find(1)) # member of project 5 only
    assert multiproject_issue.visible?(User.find(4)) # member of project 5 only, not admin
    assert !multiproject_issue.visible?(User.find(3)) # not a member
  end

  def test_anonymous_should_not_see_private_issues_with_issues_visibility_set_to_default
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  def test_anonymous_should_not_see_private_issues_with_issues_visibility_set_to_own
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  def test_anonymous_should_not_see_private_multiproject_issues_with_issues_visibility_set_to_default
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  def test_anonymous_should_not_see_private_multiproject_issues_with_issues_visibility_set_to_own
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  def test_anonymous_should_not_see_private_projects_issues_with_issues_visibility_set_to_all
    assert Role.anonymous.update_attribute(:issues_visibility, 'all')
    issue = Issue.generate!(:is_private => false, project: Project.find(2), projects: [Project.find(2),Project.find(5)]) # multiprojects issue
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible?(User.anonymous)
  end

  def test_core_visible_method_when_project_is_public
    issue = Issue.find(1) # project_id = 1
    assert issue.visible_without_multiproject_issues?(User.anonymous)
    assert issue.visible_without_multiproject_issues?(User.find(8))
  end

  def test_core_visible_method_when_project_is_private
    issue = Issue.generate!(:is_private => false, project: Project.find(2))
    assert !issue.visible_without_multiproject_issues?(User.anonymous), ": issue (#{issue.inspect}) should not be visible when user is not set and project is private"
    assert issue.visible_without_multiproject_issues?(User.find(8)) # member of project 2
    assert !issue.visible_without_multiproject_issues?(User.find(3)) # not a member
  end

  def test_core_visible_method_when_issue_has_several_projects
    multiprojects_issue = Issue.find(4) # project_id = 2
    assert multiprojects_issue.projects.size > 1
    assert !multiprojects_issue.visible_without_multiproject_issues?(User.anonymous)
    assert multiprojects_issue.visible_without_multiproject_issues?(User.find(8)) # member of project 2 and 5
    assert multiprojects_issue.visible_without_multiproject_issues?(User.find(1)) # member of project 5 only, but admin
    assert !multiprojects_issue.visible_without_multiproject_issues?(User.find(4)) # member of project 5 only, not admin
    assert !multiprojects_issue.visible_without_multiproject_issues?(User.find(3)) # not a member
  end

  def test_core_visible_method_anonymous_should_not_see_private_issues_with_issues_visibility_set_to_default
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  def test_core_visible_method_anonymous_should_not_see_private_issues_with_issues_visibility_set_to_own
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  def test_core_visible_method_anonymous_should_not_see_private_multiproject_issues_with_issues_visibility_set_to_default
    assert Role.anonymous.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  def test_core_visible_method_anonymous_should_not_see_private_multiproject_issues_with_issues_visibility_set_to_own
    assert Role.anonymous.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  def test_core_visible_method_anonymous_should_not_see_private_projects_issues_with_issues_visibility_set_to_all
    assert Role.anonymous.update_attribute(:issues_visibility, 'all')
    issue = Issue.generate!(:is_private => false, project: Project.find(2), projects: [Project.find(2),Project.find(5)]) # multiprojects issue
    assert_nil Issue.where(:id => issue.id).visible(User.anonymous).first
    assert !issue.visible_without_multiproject_issues?(User.anonymous)
  end

  def test_other_project_visible_method_when_issue_has_no_other_project
    issue = Issue.find(1)
    assert !issue.other_project_visible?(User.anonymous)
    assert !issue.other_project_visible?(User.find(8))
  end

  def test_other_project_visible_method_when_issue_has_several_projects
    multiprojects_issue = Issue.find(4) # project_id = 2
    assert multiprojects_issue.projects.size > 1
    assert !multiprojects_issue.other_project_visible?(User.anonymous)
    assert multiprojects_issue.other_project_visible?(User.find(8)) # member of project 2 and 5
    assert multiprojects_issue.other_project_visible?(User.find(1)) # member of project 5 only, but admin
    assert multiprojects_issue.other_project_visible?(User.find(4)) # member of project 5 only, not admin
    assert !multiprojects_issue.other_project_visible?(User.find(3)) # not a member
  end

  def test_other_project_visible_method_user_should_not_see_private_issues_with_issues_visibility_set_to_default
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  def test_other_project_visible_method_user_should_not_see_private_issues_with_issues_visibility_set_to_own
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true)
    assert_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  def test_other_project_visible_method_user_should_not_see_private_multiproject_issues_with_issues_visibility_set_to_default
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'default')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_not_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  def test_other_project_visible_method_member_should_not_see_private_multiproject_issues_with_issues_visibility_set_to_own
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'own')
    issue = Issue.generate!(:author => User.anonymous, :assigned_to => User.anonymous, :is_private => true, project_ids: [2,5])
    assert_not_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert !issue.other_project_visible?(User.find(8))
  end

  def test_other_project_visible_method_member_should_see_private_projects_issues_with_issues_visibility_set_to_all
    assert Member.find(7).roles.first.update_attribute(:issues_visibility, 'all')
    issue = Issue.generate!(:is_private => false, project: Project.find(2), projects: [Project.find(2),Project.find(5)]) # multiprojects issue
    assert_not_nil Issue.where(:id => issue.id).visible(User.find(8)).first
    assert issue.other_project_visible?(User.find(8))
  end

  def test_visible_condition_when_there_are_authorized_projects
    assert_include "issues_projects", Issue.visible_condition(User.find(4)) # should include issues_projects table name
  end

  def test_visible_condition_when_there_are_no_authorized_projects
    assert_not_include "issues_projects", Issue.visible_condition(User.anonymous) # should not include issues_projects table name
  end

  def test_core_visible_condition_when_there_are_no_authorized_projects
    assert_not_include "issues_projects", Issue.visible_condition_without_multiproject_issues(User.find(4)) # should not include issues_projects table name
  end

  def test_notified_users_from_other_projects
    issue = Issue.find(4)
    notified_users_from_other_projects = issue.notified_users_from_other_projects
    assert_not_nil notified_users_from_other_projects
    assert_not_includes notified_users_from_other_projects, User.anonymous
    assert_includes notified_users_from_other_projects, User.find(1) # member of project 5 only, but admin
    assert_not_includes notified_users_from_other_projects, User.find(3) # not a member
    assert_includes notified_users_from_other_projects, User.find(4) # member of project 5 only, not admin
    assert_not_includes notified_users_from_other_projects, User.find(8) # member of project 2 and 5 but mail_notification = only_my_events
  end

  def test_notified_users_from_main_project
    issue = Issue.find(4)
    notified_users_from_main_project = issue.notified_users_without_multiproject_issues
    assert_not_nil notified_users_from_main_project
    assert_not_includes notified_users_from_main_project, User.anonymous
    assert_not_includes notified_users_from_main_project, User.find(1) # member of project 5 only, but admin
    assert_includes notified_users_from_main_project, User.find(2) # member of main project 2
    assert_not_includes notified_users_from_main_project, User.find(3) # not a member
    assert_not_includes notified_users_from_main_project, User.find(4) # member of project 5 only, not admin
    assert_not_includes notified_users_from_main_project, User.find(8) # member of project 2 and 5 but mail_notification = only_my_events
  end

  def test_notified_users_should_include_previous_assignee
    user = User.find(3)
    user.members.update_all ["mail_notification = ?", false]
    user.update_attribute :mail_notification, 'only_assigned'

    issue = Issue.find(2)
    issue.assigned_to = nil
    assert_include user, issue.notified_users
    issue.save!
    assert !issue.notified_users.include?(user)
  end

  def test_notified_users_should_not_include_users_that_cannot_view_the_issue
    issue = Issue.find(12)
    assert issue.notified_users.include?(issue.author)
    # copy the issue to a private project
    copy  = issue.copy(:author_id => issue.author.id, :project_id => 5, :tracker_id => 2)
    # author is not a member of project anymore
    assert !copy.notified_users.include?(copy.author)
  end

  def test_editable_allows_member_of_secondary_project_to_edit_issue
    issue = Issue.find(4)
    issue.update_attribute(:answers_on_secondary_projects, true)
    user = User.find(4) #member of project(5)
    assert !user.member_of?(issue.project) #but not member of main project
    #go
    assert issue.editable?(user), "user(4) should be able to edit issue(4) as it is editable on secondary projects"
    assert issue.safe_attribute_names(user).include?("notes")
  end

  def test_editable_doesnt_allow_member_of_secondary_project_to_edit_issue_if_forbidden
    issue = Issue.find(4)
    issue.update_attribute(:answers_on_secondary_projects, false)
    user = User.find(4) #member of project(5)
    assert !user.member_of?(issue.project) #but not member of main project
    #go
    assert !issue.editable?(user), "user(4) should be able to edit issue(4) as it is editable on secondary projects"
    assert !issue.safe_attribute_names(user).include?("notes")
  end
end
