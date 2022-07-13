module MultiprojectsIssueHelper
  def custom_values_by_projects(projects, custom_fields)
    values_by_projects = {}
    enumeration_values = {}
    CustomFieldEnumeration.select(:id, :name)
                          .joins(:custom_field)
                          .where(:custom_field_id => custom_fields.map(&:id))
                          .order(:id)
                          .each { |enum|
                            enumeration_values[enum.id] = enum.name
                          }
    projects.each do |project|
      values_by_projects.merge!(project.id => {})
      custom_fields.each do |custom_field|
        values = custom_field.custom_values.select { |cv| cv.customized_id == project.id }
        values.each do |custom_value|
          if custom_field.field_format == 'enumeration'
            value = enumeration_values[custom_value.value.to_i]
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
