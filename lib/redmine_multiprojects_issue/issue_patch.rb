require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects

  alias_method :core_visible?, :visible?
  alias_method :core_notified_users, :notified_users
  self.singleton_class.send(:alias_method, :core_visible_condition, :visible_condition)

  # Returns true if usr or current user is allowed to view the issue
  def visible?(usr=nil)
    core_visible?(usr) || other_project_visible?(usr)
  end

  def other_project_visible?(usr=nil)
    other_projects = self.projects - [self.project]
    visible_projects = other_projects.detect do |p|
      (usr || User.current).allowed_to?(:view_issues, p) do |role, user|
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
    end
    visible_projects.present?
  end

  def self.visible_condition(user, options={})

    statement_by_role = {}
    user.projects_by_role.each do |role, projects|
      if role.allowed_to?(:view_issues) && projects.any?
        statement_by_role[role] = "project_id IN (#{projects.collect(&:id).join(',')})"
      end
    end
    authorized_projects = statement_by_role.values.join(' OR ')

    if authorized_projects.present?
      "(#{core_visible_condition(user, options)} OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE (#{authorized_projects}) ))"
    else
      core_visible_condition(user, options)
    end

  end

  # Returns the users that should be notified
  def notified_users
    core_notified_users | notified_users_from_other_projects
  end

  def notified_users_from_other_projects
    notified = []
    other_projects = self.projects - [self.project]
    other_projects.each do |p|

      notified_by_role = []
      p.users_by_role.each do |role, members|
        if role.allowed_to?(:view_issues)
          case role.issues_visibility
            when 'all'
              notified_by_role = notified_by_role | members
            when 'default'
              notified_by_role = notified_by_role | members if !self.is_private?
            when 'own'
              nil
            else
              nil
          end
        end
      end

      # users are notified only if :
      # - they are member and they have appropriate role
      # or
      # - they are member and they are admin
      members = p.notified_users
      notified = notified | (notified_by_role & members) | (User.where("admin = ?", true).all & members)

    end
    notified.compact
  end

end
