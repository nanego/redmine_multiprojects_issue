require_dependency 'query'

class Query

  alias_method :core_project_statement, :project_statement

  def project_statement
    project_clauses = core_project_statement

    if project_clauses
      "((#{project_clauses}) OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{project.id}))"
    else
      nil
    end

  end

end
