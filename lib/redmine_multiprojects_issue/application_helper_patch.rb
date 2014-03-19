module ApplicationHelper

  alias_method :core_link_to_project, :link_to_project

  # Do not create a link to a project when the current user is not allowed to see this project
  def link_to_project(project, options={}, html_options = nil)
    if (project.is_public? || User.current.admin? || User.current.member_of?(project))
      core_link_to_project(project, options, html_options)
    else
      "<span class='disabled_project'>#{h(project.name)}</span>".html_safe
    end
  end

end
