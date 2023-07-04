RedmineApp::Application.routes.draw do
  post :plugin_multiprojects_issue_load_projects_selection, :to => "issues#load_projects_selection"
end
