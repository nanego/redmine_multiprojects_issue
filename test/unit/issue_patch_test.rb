require File.expand_path('../../test_helper', __FILE__)

require 'redmine_multiprojects_issue/issue_patch.rb'

class IssueMultiprojectsPatchTest < ActiveSupport::TestCase
  # We need tests to ensure we don't break everything when upgrading and core methods change
  # This is especially hard to ensure the method in the core doesn't change. We have at least
  # those possibilities:
  # 1/ verify the checksum of the file in the core (what I do in redmine_scn for some core methods...) => review becomes a pain but it works
  # 2/ add some simple tests for the core method => maybe better?
  # 3/ copy all relevant core's test suite
  #
  # TODO: add tests for core's Issue#visible?
  # TODO: add tests for core's Issue.visible_condition
  # TODO: add tests for core's Issue#notified_users

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

  def test_other_project_visible
    assert false # TODO
    # => + test each case if it stays that complex (see redmine core tests...)
  end

  def test_visible_condition_when_there_are_authorized_projects
    assert false # TODO
  end

  def test_visible_condition_when_there_are_no_authorized_projects
    assert false # TODO
  end

  def test_notified_users_from_other_projects
    assert false # TODO
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

end
