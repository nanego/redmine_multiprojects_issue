module RedmineMultiprojectsIssue
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("multiprojects_issue", :plugin => "redmine_multiprojects_issue") +
        javascript_include_tag("multiprojects_issue", :plugin => "redmine_multiprojects_issue")
    end
  end
end
