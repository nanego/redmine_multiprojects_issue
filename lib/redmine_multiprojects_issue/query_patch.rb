require_dependency 'query'

class Query

  def project_statement
    project_clauses = []
    if project && !project.descendants.active.empty? # || projects
      ids = [project.id]#|projects.collect(&:id)
      if has_filter?("subproject_id")
        case operator_for("subproject_id")
          when '='
            # include the selected subprojects
            ids += values_for("subproject_id").each(&:to_i)
          when '!*'
            # main project only
          else
            # all subprojects
            ids += project.descendants.collect(&:id)
        end
      elsif Setting.display_subprojects_issues?
        ids += project.descendants.collect(&:id)
      end
      project_clauses << "#{Project.table_name}.id IN (%s)" % ids.join(',')
    elsif project
      project_clauses << "#{Project.table_name}.id = %d" % project.id
    end

    if project_clauses.any?
      "((#{project_clauses.join(' AND ')}) OR issues.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{project.id}))"
    else
      nil
    end

  end

end
