require_dependency 'issues_controller'

class IssuesController

  append_before_filter :set_projects, :only => [:create, :update]

  before_filter :authorize, :except => [:index, :load_projects_selection]

  def load_projects_selection
    @issue = Issue.find(params[:id])
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

end