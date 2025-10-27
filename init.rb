require 'redmine'
require_relative 'lib/redmine_multiprojects_issue/hooks'

Redmine::Plugin.register :redmine_multiprojects_issue do
  name 'Redmine Multiple Projects per Issue plugin'
  author 'Vincent ROBERT'
  description 'This plugin for Redmine allows more than one project per issue.'
  version '5.0.2'
  url 'https://github.com/nanego/redmine_multiprojects_issue'
  author_url 'mailto:contact@vincent-robert.com'
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  settings :default => { 'custom_fields' => []},
           :partial => 'settings/redmine_plugin_multiprojects_issue_settings'

  activity_provider :issues_from_current_project_only, :class_name => ['Issue', 'Journal'] unless Rails.env.test?
  project_module :issue_tracking do
    permission :link_other_projects_to_issue, {}, :require => :member
    permission :view_related_issues_in_secondary_projects, {}, :read => true
  end
end
