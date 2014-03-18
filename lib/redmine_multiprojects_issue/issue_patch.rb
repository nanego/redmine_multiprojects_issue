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
    # TODO: this method is super complex and has a lot in common with Issue#visible? => simplify it
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
        # TODO: remove this, there should be a simpler/cleaner way no ? (with Array#detect or Array#inject for instance)
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

    if authorized_projects.present?
      "(#{core_visible_condition(user, options)} OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE (#{authorized_projects}) ))"
    else
      core_visible_condition(user, options)
    end

  end

  # Returns the users that should be notified
  def notified_users
    notified = core_notified_users
    notified_only_from_other_projects = notified_users_from_other_projects - notified
    notified_only_from_other_projects.reject! {|user| !other_project_visible?(user)} # Remove users who cannot view the issue  # TODO Improve performance when the issue has many projects
    notified_only_from_other_projects | notified
  end

  def notified_users_from_other_projects
    notified = []
    other_projects = self.projects - [self.project]
    other_projects.each do |p|
      notified = notified | p.notified_users
    end
    notified
  end

end

# TODO: why is it here ??
require_dependency 'issues_helper'

module IssuesHelper

  alias_method :core_show_detail, :show_detail

  # Returns the textual representation of a single journal detail
  # TODO: simplify this method and/or explain the patch
  def show_detail(detail, no_html=false, options={})

    # TODO: add comments around parts of the method that have been modified for future review
    if detail.property == 'projects'
      value = detail.value
      old_value = detail.old_value
      if value.present?
        value = value.split(',')
        list = content_tag("span", h(value.join(', ')), class: "journal_projects_details", data: {detail_id: detail.id}, style: value.size>1 ? "display:none;":"")
        link = link_to l(:label_details).downcase, "#", class: "show_journal_details", data: {detail_id: detail.id} if value.size>1
        details = "(#{link}#{list})" unless no_html
        "#{value.size} #{value.size>1 ? l(:text_journal_projects_added) : l(:text_journal_project_added)} #{details}".html_safe
      elsif old_value.present?
        old_value = old_value.split(',')
        list = content_tag("del", h(old_value.join(', ')), class: "journal_projects_details", data: {detail_id: detail.id}, style: old_value.size>1 ? "display:none;":"")
        link = link_to l(:label_details).downcase, "#", class: "show_journal_details", data: {detail_id: detail.id} if old_value.size>1
        details = "(#{link}#{list})" unless no_html
        "#{old_value.size} #{old_value.size>1 ? l(:text_journal_projects_deleted) : l(:text_journal_project_deleted)} #{details}".html_safe
      end
    else
      core_show_detail(detail, no_html, options)
    end

  end

end
