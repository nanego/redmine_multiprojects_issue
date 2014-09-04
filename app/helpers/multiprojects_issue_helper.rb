module MultiprojectsIssueHelper
  def custom_values_by_projects(projects, custom_fields)
    values_by_projects = {}
    projects.each do |project|
      values_by_projects.merge!(project.id => {})
    end
    values = CustomValue.where("customized_type = ? AND customized_id IN (?) AND custom_field_id IN (?)", Project.name.demodulize, projects.map(&:id), custom_fields.map(&:id) )
    values.each do |value|
      values_by_projects[value.customized_id].merge!(value.custom_field_id => value.value)
    end
    values_by_projects
  end
end
