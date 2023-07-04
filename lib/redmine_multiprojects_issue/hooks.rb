require File.dirname(__FILE__) + '/../../app/helpers/multiprojects_issue_helper'
include MultiprojectsIssueHelper

module RedmineMultiprojectsIssue

  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("multiprojects_issue", :plugin => "redmine_multiprojects_issue") +
        javascript_include_tag("multiprojects_issue", :plugin => "redmine_multiprojects_issue")
    end
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'issue_patch'
      require_relative 'journal_patch'
      require_relative 'issues_helper_patch'
      require_relative 'issues_controller_patch'
      require_relative 'issue_query_patch'
      require_relative 'issue_custom_field_patch' unless Rails.env.test?
      require_relative 'query_patch' unless Rails.env.test?
      require_relative 'queries_helper_patch'
      require_relative 'activity_fetcher_patch.rb'
      require_relative 'acts_as_activity_provider_patch.rb'
      require_relative 'application_helper_patch'
    end
  end

end
