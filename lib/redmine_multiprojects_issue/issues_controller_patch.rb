require_dependency 'issues_controller'

class IssuesController < ApplicationController

  before_action :authorize, :except => [:index, :new, :create, :load_projects_selection, :show]
  before_action :set_project, :only => [:load_projects_selection]
  append_before_action :set_assignable_projects, :only => [:create, :update]

  skip_forgery_protection only: :load_projects_selection

  def load_projects_selection
    if params[:issue_id]
      @issue = Issue.where(id: params[:issue_id]).first
    end
    if @issue.blank?
      @issue = Issue.new
    end
    @issue.project = @project
    @select_tag_id = params[:select_tag_id]
  end

  private

    def set_assignable_projects
      if params[:issue] && params[:issue][:project_ids]
        @projects = []
        params[:issue][:project_ids].reject!(&:blank?)
        if params[:issue][:project_ids].present?
          Project.find(params[:issue][:project_ids]).each do |p|
            next unless User.current.allowed_to?(:add_issues, p)

            @projects << p unless (params[:project_id] == p.id.to_s || params[:issue][:project_id]  == p.id.to_s)
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
                                                    :value => (@projects - @projects_before_change).reject(&:blank?).join(","))  if (@projects - @projects_before_change - [@issue.project]).present?
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
end
