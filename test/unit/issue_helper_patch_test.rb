require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/issues_helper_patch.rb'

class IssueHelperMultiprojectsIssuePatchTest < ActionView::TestCase
  include ApplicationHelper
  include IssuesHelper
  include CustomFieldsHelper
  include ERB::Util

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :custom_fields,
           :attachments,
           :versions

  def setup
    super
    set_language_if_valid('en')
    User.current = nil
  end

  ### custom tests for 'projects' property

  test 'IssuesHelper#show_detail with no_html should show a changing project' do
    detail = JournalDetail.new(:property => 'projects', :old_value => nil, :value => 'CookBook project', :prop_key => nil)
    assert_equal "CookBook project", show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail with no_html should show a deleted project' do
    detail = JournalDetail.new(:property => 'projects', :old_value => 'Wrong project', :value => nil, :prop_key => nil)
    assert_equal "Wrong project", show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail with html should show a new project with HTML highlights' do
    detail = JournalDetail.new(:property => 'projects', :old_value => nil, :value => 'CookBook', :prop_key => nil)
    detail.id = 1
    result = show_detail(detail, false)
    assert_include "1 added project (<span class=\"journal_projects_details\" data-detail-id=\"1\"", result
    assert_include "CookBook</span>)", result
  end

  test 'IssuesHelper#show_detail with html should show a deleted project with HTML highlights' do
    detail = JournalDetail.new(:property => 'projects', :old_value => 'CookBook', :value => nil, :prop_key => nil)
    html = show_detail(detail, false)
    assert_include '1 deleted project (<del class="journal_projects_details" data-detail-id="null"', html
    assert_include 'CookBook</del>)', html
  end

  test 'IssuesHelper#show_detail with html should show all new projects with HTML highlights' do
    detail = JournalDetail.new(:property => 'projects', :old_value => nil, :value => 'CookBook,OnlineStore', :prop_key => nil)
    detail.id = 1
    result = show_detail(detail, false)
    html = "2 added projects (<a href=\"#\" class=\"show_journal_details\" data-detail-id=\"1\">details</a><a href=\"#\" class=\"hide_journal_details\" data-detail-id=\"1\">hide</a><span class=\"journal_projects_details\" data-detail-id=\"1\" style=\"display:none;\">CookBook, OnlineStore</span>)"
    assert_include html, result
  end

  test 'IssuesHelper#show_detail with html should show all deleted projects with HTML highlights' do
    detail = JournalDetail.new(:property => 'projects', :old_value => 'CookBook,OnlineStore', :value => nil, :prop_key => nil)
    result = show_detail(detail, false)
    html = "2 deleted projects (<a href=\"#\" class=\"show_journal_details\" data-detail-id=\"null\">details</a><a href=\"#\" class=\"hide_journal_details\" data-detail-id=\"null\">hide</a><del class=\"journal_projects_details\" data-detail-id=\"null\" style=\"display:none;\">CookBook, OnlineStore</del>)"
    assert_include html, result
  end

  ### core tests for core properties ('attr', 'attachment' and 'cf')

  test 'IssuesHelper#show_detail with no_html should show a changing attribute' do
    detail = JournalDetail.new(:property => 'attr', :old_value => '40', :value => '100', :prop_key => 'done_ratio')
    assert_equal "% Done changed from 40 to 100", show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail with no_html should show a new attribute' do
    detail = JournalDetail.new(:property => 'attr', :old_value => nil, :value => '100', :prop_key => 'done_ratio')
    assert_equal "% Done set to 100", show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail with no_html should show a deleted attribute' do
    detail = JournalDetail.new(:property => 'attr', :old_value => '50', :value => nil, :prop_key => 'done_ratio')
    assert_equal "% Done deleted (50)", show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail with html should show a changing attribute with HTML highlights' do
    detail = JournalDetail.new(:property => 'attr', :old_value => '40', :value => '100', :prop_key => 'done_ratio')
    html = show_detail(detail, false)

    assert_include '<strong>% Done</strong>', html
    assert_include '<i>40</i>', html
    assert_include '<i>100</i>', html
  end

  test 'IssuesHelper#show_detail with html should show a new attribute with HTML highlights' do
    detail = JournalDetail.new(:property => 'attr', :old_value => nil, :value => '100', :prop_key => 'done_ratio')
    html = show_detail(detail, false)

    assert_include '<strong>% Done</strong>', html
    assert_include '<i>100</i>', html
  end

  test 'IssuesHelper#show_detail with html should show a deleted attribute with HTML highlights' do
    detail = JournalDetail.new(:property => 'attr', :old_value => '50', :value => nil, :prop_key => 'done_ratio')
    html = show_detail(detail, false)

    assert_include '<strong>% Done</strong>', html
    assert_include '<del><i>50</i></del>', html
  end

  test 'IssuesHelper#show_detail with a start_date attribute should format the dates' do
    detail = JournalDetail.new(
        :property  => 'attr',
        :old_value => '2010-01-01',
        :value     => '2010-01-31',
        :prop_key  => 'start_date'
    )
    with_settings :date_format => '%m/%d/%Y' do
      assert_match "01/31/2010", show_detail(detail, true)
      assert_match "01/01/2010", show_detail(detail, true)
    end
  end

  test 'IssuesHelper#show_detail with a due_date attribute should format the dates' do
    detail = JournalDetail.new(
        :property  => 'attr',
        :old_value => '2010-01-01',
        :value     => '2010-01-31',
        :prop_key  => 'due_date'
    )
    with_settings :date_format => '%m/%d/%Y' do
      assert_match "01/31/2010", show_detail(detail, true)
      assert_match "01/01/2010", show_detail(detail, true)
    end
  end

  test 'IssuesHelper#show_detail should show old and new values with a project attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'project_id', :old_value => 1, :value => 2)
    assert_match 'eCookbook', show_detail(detail, true)
    assert_match 'OnlineStore', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a issue status attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'status_id', :old_value => 1, :value => 2)
    assert_match 'New', show_detail(detail, true)
    assert_match 'Assigned', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a tracker attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'tracker_id', :old_value => 1, :value => 2)
    assert_match 'Bug', show_detail(detail, true)
    assert_match 'Feature request', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a assigned to attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'assigned_to_id', :old_value => 1, :value => 2)
    assert_match 'Redmine Admin', show_detail(detail, true)
    assert_match 'John Smith', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a priority attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'priority_id', :old_value => 4, :value => 5)
    assert_match 'Low', show_detail(detail, true)
    assert_match 'Normal', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a category attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'category_id', :old_value => 1, :value => 2)
    assert_match 'Printing', show_detail(detail, true)
    assert_match 'Recipes', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a fixed version attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'fixed_version_id', :old_value => 1, :value => 2)
    assert_match '0.1', show_detail(detail, true)
    assert_match '1.0', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a estimated hours attribute' do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'estimated_hours', :old_value => '5', :value => '6.3')
    assert_match '5.00', show_detail(detail, true)
    assert_match '6.30', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show old and new values with a custom field' do
    detail = JournalDetail.new(:property => 'cf', :prop_key => '1', :old_value => 'MySQL', :value => 'PostgreSQL')
    assert_equal 'Database changed from MySQL to PostgreSQL', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show added file' do
    detail = JournalDetail.new(:property => 'attachment', :prop_key => '1', :old_value => nil, :value => 'error281.txt')
    assert_match 'error281.txt', show_detail(detail, true)
  end

  test 'IssuesHelper#show_detail should show removed file' do
    detail = JournalDetail.new(:property => 'attachment', :prop_key => '1', :old_value => 'error281.txt', :value => nil)
    assert_match 'error281.txt', show_detail(detail, true)
  end

end
