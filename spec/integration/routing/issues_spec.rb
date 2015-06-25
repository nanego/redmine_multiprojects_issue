require "spec_helper"

describe "RoutingIssues" do
  it "should issues ajax action" do
    assert_routing(
        { :method => 'get', :remote => true, :path => "/plugin_multiprojects_issue_load_projects_selection" },
        { :controller => 'issues', :action => 'load_projects_selection' }
    )
  end
end
