require 'redmine'

ActiveSupport::Reloader.to_prepare do
  require_dependency 'redmine_multiprojects_issue/hooks'
  require_dependency 'redmine_multiprojects_issue/issue_patch'
  require_dependency 'redmine_multiprojects_issue/journal_patch'
  require_dependency 'redmine_multiprojects_issue/issues_helper_patch'
  require_dependency 'redmine_multiprojects_issue/issues_controller_patch'
  require_dependency 'redmine_multiprojects_issue/issue_query_patch'
  require_dependency 'redmine_multiprojects_issue/issue_custom_field_patch' unless Rails.env.test?
  require_dependency 'redmine_multiprojects_issue/query_patch' unless Rails.env.test?
  require_dependency 'redmine_multiprojects_issue/queries_helper_patch'
  require_dependency 'redmine_multiprojects_issue/activity_fetcher_patch.rb'
  require_dependency 'redmine_multiprojects_issue/acts_as_activity_provider.rb'
end

Redmine::Plugin.register :redmine_multiprojects_issue do
  name 'Redmine Multiple Projects per Issue plugin'
  author 'Vincent ROBERT'
  description 'This plugin for Redmine allows more than one project per issue.'
  version '4.1.1'
  url 'https://github.com/nanego/redmine_multiprojects_issue'
  author_url 'mailto:contact@vincent-robert.com'
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  requires_redmine_plugin :redmine_base_stimulusjs, :version_or_higher => '1.0.1'
  settings :default => { 'custom_fields' => []},
           :partial => 'settings/redmine_plugin_multiprojects_issue_settings'

  activity_provider :issues_from_current_project_only, :class_name => ['Issue', 'Journal'] unless Rails.env.test?
  project_module :issue_tracking do
    permission :link_other_projects_to_issue, {}, :require => :member
    permission :view_related_issues_in_secondary_projects, {}, :read => true
  end
end
