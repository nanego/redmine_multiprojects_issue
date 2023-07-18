require_dependency 'application_helper'

module RedmineMultiprojectsIssue
  module ApplicationHelperPatch

    # adapted from standard method "is_descendant_of?(other)"
    def is_descendant_of_by_attributes?(project, other_project)
      # project, other_project are represented by array [:id, :name, :status, :lft, :rgt]
      project_lft = project[3]
      project_rgt = project[4]
      other_project_lft = other_project[3]
      other_project_rgt = other_project[4]

      other_project_lft < project_lft && other_project_rgt > project_rgt
    end

    # This function simulate  render_project_nested_lists, but projects are an array of attributes not activerecord
    def render_project_nested_lists_by_attributes(projects, &block)
      s = +''
      if projects.any?
        ancestors = []
        # in the orginal method we write projects.sort_by(&:lft).each do |project|
        # but here the projects array is already sorted by lft before sending by ajax
        projects.each do |project|
          project_status = project[0]
          project_name = project[1]
          # use is_descendant_of_by_attributes instead of is_descendant_of
          if ancestors.empty? || is_descendant_of_by_attributes?(project, ancestors.last)
            s << "<ul class='projects #{ancestors.empty? ? 'root' : nil}'>\n"
          else
            ancestors.pop
            s << "</li>"
            while ancestors.any? && !is_descendant_of_by_attributes?(project, ancestors.last)
              ancestors.pop
              s << "</ul></li>\n"
            end
          end
          classes = (ancestors.empty? ? 'root' : 'child')
          # use the condition project_status ==  Project::STATUS_ARCHIVED instead of  project.archived?
          classes += ' archived' if project_status == Project::STATUS_ARCHIVED
          s << "<li class='#{classes}'><div class='#{classes}'>"
          s << h(block_given? ? capture(project, &block) : project_name)
          s << "</div>\n"
          ancestors << project
        end
        s << ("</li></ul>\n" * ancestors.size)
      end
      s.html_safe
    end
  end
end

ApplicationHelper.prepend RedmineMultiprojectsIssue::ApplicationHelperPatch
ActionView::Base.prepend ApplicationHelper
