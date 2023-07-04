require_dependency 'application_helper'

module RedmineMultiprojectsIssue
  module ApplicationHelperPatch

  	def is_descendant_of_by_attributes?(project , other)
  		# project is presented by array [:id, :name, :status, :lft, :rgt]
    	other[3] < project[3] && other[4] > project[4]    	
  	end

	  # This function simulate  render_project_nested_lists, but projects are an array of attributes not activerecord
	  def render_project_nested_lists_by_attributes(projects, &block)
	    s = +''
	    if projects.any?
	      ancestors = []
	      projects.each do |project|	      	 
	      	project_status = project[0]
     			project_name = project[1]

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
	        classes += ' archived' if  project_status ==  Project::STATUS_ARCHIVED
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