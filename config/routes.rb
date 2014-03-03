RedmineApp::Application.routes.draw do
  resources :issues do
    member {get :load_projects_selection}
  end
end
