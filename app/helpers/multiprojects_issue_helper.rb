module MultiprojectsIssueHelper
  def custom_values_by_projects(projects, custom_fields)
    values_by_projects = {}
    projects.each do |project|
      values_by_projects.merge!(project.id => {})
      custom_fields.each do |custom_field|
        values = custom_field.custom_values.select { |cv| cv.customized_id == project.id }
        values.each do |custom_value|
          if custom_field.field_format == 'enumeration'
            value = CustomFieldEnumeration.where(id: custom_value.value.to_i).first.to_s
          else
            value = custom_value.value
          end
          values_by_projects[project.id].merge!(custom_field.id => value) if value.present?
        end
      end
    end
    values_by_projects
  end
end
