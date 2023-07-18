require_dependency 'issues_controller'

module RedmineMultiprojectsIssue::IssuesControllerPatch
  def load_projects_selection
    if params[:issue_id]
      @issue = Issue.where(id: params[:issue_id]).first
    end
    if @issue.blank?
      @issue = Issue.new
    end

    @issue.project = @project
    @select_tag_id = params[:select_tag_id]

    if params[:project_ids]
      project_ids = params[:project_ids].split(',')
      issue_projects_attributes_array = (project_ids.present? ? Project.find(project_ids).pluck(:id, :name, :status, :lft, :rgt) : [])
    end

    issue_project_attribute = [@issue.project.id, @issue.project.name, @issue.project.status, @issue.project.lft, @issue.project.rgt]
    @issue_projects_attributes_array = issue_projects_attributes_array | [issue_project_attribute]

    vals = Rails.env.test? ? JSON.parse(params[:allowed_projects]) : params[:allowed_projects].permit!.to_h.values
    # convert to int 
    allowed_target_projects_attributes_array = vals.map do |id, name, status, lft, rgt|
      [id.to_i, name, status.to_i, lft.to_i, rgt.to_i]
    end

    @allowed_target_projects_attributes_array = allowed_target_projects_attributes_array - [issue_project_attribute]

    render json: { html: render_to_string(partial: 'modal_select_projects.html') }
  end

  private

  def set_assignable_projects
    if !User.current.admin? && !User.current.allowed_to?(:link_other_projects_to_issue, @issue.project)
      @issue.assignable_projects = @issue.projects
      return
    end
    if params[:issue] && params[:issue][:project_ids]
      @projects = []
      params[:issue][:project_ids].reject!(&:blank?)
      if params[:issue][:project_ids].present?
        Project.find(params[:issue][:project_ids]).each do |p|
          @projects << p unless (params[:project_id] == p.id.to_s || params[:issue][:project_id] == p.id.to_s)
        end
      end
      @projects.uniq!
      update_journal_with_projects unless @issue.new_record?
      @issue.assignable_projects = @projects
    end
  end

  def update_journal_with_projects
    @current_journal = @issue.init_journal(User.current)
    @projects_before_change = @issue.projects
    # projects removed
    @current_journal.details << JournalDetail.new(:property => 'projects',
                                                  :old_value => (@projects_before_change - @projects).reject(&:blank?).join(","),
                                                  :value => nil) if (@projects_before_change - @projects - [@issue.project]).present?
    # projects added
    @current_journal.details << JournalDetail.new(:property => 'projects',
                                                  :old_value => nil,
                                                  :value => (@projects - @projects_before_change).reject(&:blank?).join(",")) if (@projects - @projects_before_change - [@issue.project]).present?
  end

  def set_project
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Override #authorize method locally to handle answers on secondary project
  # Note that this is NOT a good idea if other plugins override it :/
  def authorize(ctrl = params[:controller], action = params[:action], global = false)
    if ctrl == "issues" && action == "update"
      @issue.editable?
    else
      super
    end
  end

  def get_allowed_target_projects
    @issue = Issue.find(params[:id]) unless @issue.present?
    @allowed_target_projects = @issue.allowed_target_projects
  end

end

IssuesController.prepend RedmineMultiprojectsIssue::IssuesControllerPatch

class IssuesController < ApplicationController

  before_action :authorize, :except => [:index, :new, :create, :load_projects_selection, :show]
  before_action :set_project, :only => [:load_projects_selection]
  append_before_action :set_assignable_projects, :only => [:create, :update]
  append_before_action :get_allowed_target_projects, :only => [:show, :edit, :new]

  skip_forgery_protection only: :load_projects_selection

end
