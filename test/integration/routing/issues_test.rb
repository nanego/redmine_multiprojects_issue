require File.expand_path('../../../test_helper', __FILE__)

class RoutingIssuesTest < ActionController::IntegrationTest
  def test_issues_ajax_action
    assert_routing(
        { :method => 'get', :remote => true, :path => "/plugin_multiprojects_issue_load_projects_selection" },
        { :controller => 'issues', :action => 'load_projects_selection' }
    )
  end
end
