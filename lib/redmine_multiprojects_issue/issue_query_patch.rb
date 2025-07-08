require_dependency 'issue_query'

module RedmineMultiprojectsIssue::IssueQueryPatch
  def project_statement(with_multiprojects = true)
    project_clauses = super()
    allowed = User.current.allowed_to?(:view_related_issues_in_secondary_projects, nil, :global => true)
    if project_clauses && project && with_multiprojects && allowed
      sanitized_project_id = ActiveRecord::Base.connection.quote(project.id) # Avoid SQL injection
      "((#{project_clauses}) OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{sanitized_project_id}))"
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


  def sql_for_any_searchable_field(field, operator, value)
    question = value.first

    # Fetch search results only from the selected and visible (sub-)projects
    project_scope = Project.allowed_to(:view_issues)
    if project


      ##### START PATCH #####

      projects = project_scope.where(project_statement(false)) # bypass overridden method, disable multiprojects feature for this filter

      ##### END PATCH #####


    elsif has_filter?('project_id')
      case values_for('project_id').first
      when 'mine'
        project_ids = User.current.projects.ids
      when 'bookmarks'
        project_ids = User.current.bookmarked_project_ids
      else
        project_ids = values_for('project_id')
      end
      projects = project_scope.where(
        sql_for_field('project_id', operator_for('project_id'), project_ids, Project.table_name, 'id')
      )
    else
      projects = nil
    end

    is_all_words =
      case operator
      when '~'        then true
      when '*~', '!~' then false
      end

    is_open_issues = has_filter?('status_id') && operator_for('status_id') == 'o'

    fetcher = Redmine::Search::Fetcher.new(
      question, User.current, ['issue'], projects,
      all_words: is_all_words, open_issues: is_open_issues, attachments: '0'
    )
    ids = fetcher.result_ids.map(&:last)
    if ids.present?
      sw = operator == '!~' ? 'NOT' : ''
      "#{Issue.table_name}.id #{sw} IN (#{ids.join(',')})"
    else
      operator == '!~' ? '1=1' : '1=0'
    end
  end
end

IssueQuery.prepend RedmineMultiprojectsIssue::IssueQueryPatch

class IssueQuery < Query
  sort_projects_by_count = "(SELECT count(i.id) FROM #{Issue.table_name} as i INNER JOIN issues_projects ON i.id = issue_id WHERE #{Issue.table_name}.id = i.id)"
  self.available_columns << QueryColumn.new(:related_projects, :sortable => sort_projects_by_count)
end
