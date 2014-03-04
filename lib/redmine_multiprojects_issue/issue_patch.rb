require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects

  alias_method :core_visible?, :visible?

  # Returns true if usr or current user is allowed to view the issue
  def visible?(usr=nil)

    other_projects = self.projects - [self.project]
    other_projects_visibility = false

    other_projects.each do |p|
      if other_projects_visibility == false
        other_projects_visibility = (usr || User.current).allowed_to?(:view_issues, p) do |role, user|
          if user.logged?
            case role.issues_visibility
              when 'all'
                true
              when 'default'
                !self.is_private? || (self.author == user || user.is_or_belongs_to?(assigned_to))
              when 'own'
                self.author == user || user.is_or_belongs_to?(assigned_to)
              else
                false
            end
          else
            !self.is_private?
          end
        end
      else
        break
      end
    end

    core_visible? || other_projects_visibility
  end

end
