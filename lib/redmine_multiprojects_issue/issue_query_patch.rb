require_dependency 'issue_query'

class IssueQuery < Query

  def project_statement(with_multiprojects = true)
    project_clauses = super()
    if project_clauses && project && with_multiprojects
      "((#{project_clauses}) OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{project.id}))"
    else
      project_clauses
    end
  end

  # Returns the versions, bypassing the project_statement method patched above
  def versions(options = {})
    Version.visible.
        where(project_statement(false)).# bypass overridden method
    where(options[:conditions]).
        includes(:project).
        references(:project).
        to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  sort_projects_by_count = "(SELECT count(i.id) FROM #{Issue.table_name} as i INNER JOIN issues_projects ON i.id = issue_id WHERE #{Issue.table_name}.id = i.id)"
  self.available_columns << QueryColumn.new(:related_projects, :sortable => sort_projects_by_count)
end
