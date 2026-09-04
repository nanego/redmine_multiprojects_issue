require_dependency 'user'

module RedmineMultiprojectsIssue
  module UserPatch
    # Memoizes the projects where the user may view related issues, see Issue.visible_condition.
    # Cleared with the core permission caches on reload.
    def related_issues_project_ids_cache
      @related_issues_project_ids_cache ||= {}
    end

    def reload(*)
      @related_issues_project_ids_cache = nil
      super
    end
  end
end

User.prepend RedmineMultiprojectsIssue::UserPatch
