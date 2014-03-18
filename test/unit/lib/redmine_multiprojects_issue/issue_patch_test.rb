require File.dirname(__FILE__) + '/../../../test_helper'

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

  def test_visible_patch
    # this one should be easy but anyway... ;)
    assert false # TODO
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

  def test_notified_users
    assert false # TODO
  end

  def test_notified_users_from_other_projects
    assert false # TODO
  end
end
