RedmineApp::Application.routes.draw do
  get :plugin_multiprojects_issue_load_projects_selection, :to => "issues#load_projects_selection"
end
