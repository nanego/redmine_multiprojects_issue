require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects
  attr_accessor :assignable_projects #List related projects before save
  after_save :set_projects

  safe_attributes 'answers_on_secondary_projects'
  #adds a new "safe_attributes condition to handle the case of secondary projects
  safe_attributes 'notes', :if => lambda {|issue, user| issue.editable?(user)}

  unless instance_methods.include?(:visible_with_multiproject_issues?)
    # Returns true if usr or current user is allowed to view the issue
    def visible_with_multiproject_issues?(usr=nil)
      visible_without_multiproject_issues?(usr) || other_project_visible?(usr)
    end
    alias_method_chain :visible?, :multiproject_issues
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

  unless methods.include?(:visible_condition_with_multiproject_issues)
    def self.visible_condition_with_multiproject_issues(user, options={})
      statement_by_role = {}
      user.projects_by_role.each do |role, projects|
        projects = projects & [options[:project]] if options[:project]
        if role.allowed_to?(:view_issues) && projects.any?
          statement_by_role[role] = "project_id IN (#{projects.collect(&:id).join(',')})"
        end
      end
      authorized_projects = statement_by_role.values.join(' OR ')

      if authorized_projects.present?
        "(#{visible_condition_without_multiproject_issues(user, options)} OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE (#{authorized_projects}) ))"
      else
        visible_condition_without_multiproject_issues(user, options)
      end
    end
    self.singleton_class.send(:alias_method_chain, :visible_condition, :multiproject_issues)
  end

  unless instance_methods.include?(:notified_users_with_multiproject_issues)
    # Returns the users that should be notified
    def notified_users_with_multiproject_issues
      notified_users_without_multiproject_issues | notified_users_from_other_projects
    end
    alias_method_chain :notified_users, :multiproject_issues
  end

  def notified_users_from_other_projects
    notified = []
    other_projects = []
    other_projects |= self.assignable_projects unless self.assignable_projects == nil
    other_projects |= self.projects
    other_projects -= [self.project]
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

  def editable_with_secondary_projects?(user=User.current)
    editable_without_secondary_projects?(user) ||
      (answers_on_secondary_projects && projects.any?{|p|
        user.allowed_to?(:edit_issues, p) || user.allowed_to?(:add_issue_notes, p)
      })
  end
  alias_method_chain :editable?, :secondary_projects

  private

    def set_projects
      self.projects = self.assignable_projects unless self.assignable_projects == nil
    end

end
