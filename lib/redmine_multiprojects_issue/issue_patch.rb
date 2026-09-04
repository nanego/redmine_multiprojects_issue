require_dependency 'issue'

module RedmineMultiprojectsIssue
  module IssuePatch
    # Returns the users that should be notified
    def notified_users
      super | notified_users_from_other_projects
    end

    # Returns true if usr or current user is allowed to view the issue
    def visible?(usr = nil)
      super || other_project_visible?(usr)
    end

    def user_tracker_permission?(user, permission)
      super || user_tracker_permission_on_other_projects?(user, permission)
    end

    module ClassMethods
      def visible_condition(user, options = {})
        return super if user.admin? || !user.allowed_to_globally?(:view_related_issues_in_secondary_projects)

        statements = related_issues_visible_statements(user, options)
        statements.empty? ? super : "(#{super} OR #{statements.join(' OR ')})"
      end

      private

      # Issues linked to a secondary project where the user is allowed to view related issues,
      # applying the same per-role rules as the core Issue.visible_condition.
      # Project ids are resolved upfront and matched with an EXISTS on the (issue_id, project_id)
      # index: cheap per-row probes keep paginated lists fast, unlike a materialized IN subquery.
      def related_issues_visible_statements(user, options)
        related_project_ids_by_visibility(user, options).filter_map do |visibility, project_ids|
          next if visibility == '1=0' || project_ids.empty?

          "(#{visibility} AND EXISTS (SELECT 1 FROM issues_projects" \
            " WHERE issues_projects.issue_id = #{table_name}.id" \
            " AND issues_projects.project_id IN (#{project_ids.join(',')})))"
        end
      end

      def related_project_ids_by_visibility(user, options)
        cache_key = options.values_at(:project, :with_subprojects, :member, :skip_pre_condition).map { |v| v.respond_to?(:id) ? v.id : v }
        user.related_issues_project_ids_cache[cache_key] ||= begin
          permission = :view_related_issues_in_secondary_projects
          roles = []
          Project.allowed_to_condition(user, permission, options) { |role, _| roles << role; nil }

          roles.group_by { |role| issues_visibility_statement(role, user) }.transform_values do |visibility_roles|
            projects_condition = Project.allowed_to_condition(user, permission, options) do |role, _|
              '1=0' unless visibility_roles.include?(role)
            end
            Project.where(projects_condition).order(:id).pluck(:id)
          end
        end
      end

      def issues_visibility_statement(role, user)
        sql =
          if user.id && user.logged?
            case role.issues_visibility
            when 'all'
              '1=1'
            when 'default'
              user_ids = [user.id] + user.groups.pluck(:id).compact
              "(#{table_name}.is_private = #{connection.quoted_false} " \
                "OR #{table_name}.author_id = #{user.id} " \
                "OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
            when 'own'
              user_ids = [user.id] + user.groups.pluck(:id).compact
              "(#{table_name}.author_id = #{user.id} OR " \
                "#{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
            else
              '1=0'
            end
          else
            "(#{table_name}.is_private = #{connection.quoted_false})"
          end
        unless role.permissions_all_trackers?(:view_issues)
          tracker_ids = role.permissions_tracker_ids(:view_issues)
          sql = tracker_ids.any? ? "(#{sql} AND #{table_name}.tracker_id IN (#{tracker_ids.join(',')}))" : '1=0'
        end
        sql
      end
    end

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end
  end
end

class Issue

  prepend RedmineMultiprojectsIssue::IssuePatch

  include ApplicationHelper

  has_and_belongs_to_many :projects
  attr_accessor :assignable_projects #List related projects before save
  after_save :set_projects

  safe_attributes 'answers_on_secondary_projects'
  #adds a new "safe_attributes condition to handle the case of secondary projects
  safe_attributes 'notes', :if => lambda { |issue, user| issue.notes_addable?(user) }

  acts_as_activity_provider :type => 'issues_from_current_project_only',
                            :scope => proc { joins(:project).preload(:project, :author, :tracker, :status) },
                            :author_key => :author_id

  # Overrides Redmine::Acts::Attachable::InstanceMethods#attachments_visible?
  def attachments_visible?(user = User.current)
    # Check if user is allowed to see attached files in at least one of the related projects
    allowed = false
    (self.projects + [self.project]).each do |project|
      allowed = allowed || user.allowed_to?(self.class.attachable_options[:view_permission], project)
      break if allowed
    end
    (respond_to?(:visible?) ? visible?(user) : true) && allowed
  end

  def other_project_visible?(usr = nil)
    other_projects = self.projects - [self.project]
    visible_projects = other_projects.detect do |p|
      (usr || User.current).allowed_to?(:view_related_issues_in_secondary_projects, p) do |role, user|
        visible = if user.logged?
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
        unless role.permissions_all_trackers?(:view_issues)
          visible &&= role.permissions_tracker_ids?(:view_issues, tracker_id)
        end
        visible
      end
    end
    visible_projects.present?
  end

  def notified_users_from_other_projects
    notified = []
    other_projects = []
    other_projects |= self.assignable_projects unless self.assignable_projects == nil
    other_projects |= self.projects
    other_projects -= [self.project]
    other_projects.each do |p|

      notified_by_role = []
      p.principals_by_role.each do |role, members|
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
      if Redmine::Plugin.installed?(:redmine_limited_visibility)
        members = members & self.involved_users(p) if p.module_enabled?("limited_visibility") && self.authorized_viewer_ids.present?
      end
      notified = notified | (notified_by_role & members) | (User.where("admin = ?", true).all & p.notified_users)

    end
    notified.compact
  end

  def user_tracker_permission_on_other_projects?(user, permission)
    # Check roles permissions on other projects
    answers_on_secondary_projects && projects.any? { |p|
      user.roles_for_project(p).select { |r| r.has_permission?(permission) }.any? { |r| r.permissions_all_trackers?(permission) || r.permissions_tracker_ids?(permission, tracker_id) }
    }
  end

  def related_projects
    RelatedProjects.new(self, projects)
  end

  # Class used to represent the related projects of an issue
  class RelatedProjects < Array
    include Redmine::I18n

    def initialize(issue, *args)
      @issue = issue
      super(*args)
    end

    def to_s(*args)
      map { |v| v.to_s }.join(', ')
    end
  end

  private

  def set_projects
    self.projects = self.assignable_projects unless self.assignable_projects == nil
  end

end
