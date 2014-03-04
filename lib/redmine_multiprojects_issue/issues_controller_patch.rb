require_dependency 'issues_controller'

class IssuesController

  append_before_filter :set_projects, :only => [:create, :update]
  before_filter :authorize, :except => [:index, :load_projects_selection, :show]
  before_filter :set_project, :only => [:load_projects_selection]

  def load_projects_selection
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
    else
      @issue = Issue.new
    end
    @issue.project = @project
  end

  private

    def set_projects
      @projects = []
      @projects << Project.find(params[:project_id]) if params[:project_id]
      if params[:issue] && params[:issue][:project_ids]
        Project.find((params[:issue][:project_ids]).reject!(&:blank?)).each do |p|
          @projects << p
        end
      end
      @projects.uniq!
      @issue.projects = @projects
    end

    def set_project
      project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

end
