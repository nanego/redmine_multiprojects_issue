require_dependency 'query'

class Query

  alias_method :core_project_statement, :project_statement

  def project_statement

    project_clauses = core_project_statement

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

end

require_dependency 'issue_query'

class IssueQuery < Query

  # Returns the versions
  # Valid options are :conditions
  def versions(options={})
    Version.visible.where(options[:conditions]).all(
        :include => :project,
        :conditions => core_project_statement
    )
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

end
