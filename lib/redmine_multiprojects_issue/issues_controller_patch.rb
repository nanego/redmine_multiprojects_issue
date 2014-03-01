require_dependency 'issues_controller'

class IssuesController

  append_before_filter :set_projects, :only => [:create, :update]

  private

    def set_projects
      @projects = [Project.find(params[:project_id])]
      @projects << Project.find((params[:issue] && params[:issue][:project_ids]).reject!(&:blank?))
      @projects.uniq!
      @issue.projects << @projects
    end

end