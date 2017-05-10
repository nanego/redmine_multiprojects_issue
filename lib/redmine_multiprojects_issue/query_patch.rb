require_dependency 'query'
require_dependency 'issue_query'

class Query
  unless instance_methods.include?(:project_statement_with_multiproject_issues)
    def project_statement_with_multiproject_issues
      project_clauses = project_statement_without_multiproject_issues
      if self.is_a?(IssueQuery)
        if project_clauses
          "((#{project_clauses}) OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{project.id}))"
        else
          nil
        end
      else
        project_clauses
      end
    end
    alias_method_chain :project_statement, :multiproject_issues
  end
end

class IssueQuery < Query
  # Returns the versions, bypassing the project_statement method patched above
  def versions(options={})
    Version.visible.
        where(project_statement_without_multiproject_issues).  # bypass patched method
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
