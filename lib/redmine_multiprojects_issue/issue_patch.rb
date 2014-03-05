require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects

  alias_method :core_visible?, :visible?
  self.singleton_class.send(:alias_method, :core_visible_condition, :visible_condition)

  # Returns true if usr or current user is allowed to view the issue
  def visible?(usr=nil)
    core_visible? || other_project_visible?
  end

  def other_project_visible?
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
    other_projects_visibility
  end

  def self.visible_condition(user, options={})

    statement_by_role = {}
    user.projects_by_role.each do |role, projects|
      if role.allowed_to?(:view_issues) && projects.any?
        statement_by_role[role] = "project_id IN (#{projects.collect(&:id).join(',')})"
      end
    end
    authorized_projects = statement_by_role.values.join(' OR ')

    "(#{core_visible_condition(user, options)} OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE (#{authorized_projects}) ))"
  end

end
