module MultiprojectsIssueHelper

  def custom_values_by_project_ids(projects, custom_fields)
    values_by_projects = {}
    enumerations_values_by_custom_fields = enumerations_values_by_custom_fields(custom_fields)

    invalidation_cache_key = Project.maximum(:updated_on).to_i

    projects.each do |project|
      project_id = project[0]
      values_by_projects[project_id] = Rails.cache.fetch("multiprojects-plugin-custom_values_by_project_ids-#{project_id}-#{custom_fields.map(&:id)}-#{invalidation_cache_key}") do
        custom_fields_values = {}
        custom_fields.each do |custom_field|
          values = custom_field.custom_values.select { |cv| cv.customized_id == project_id }
          values.each do |custom_value|
            if custom_field.field_format == 'enumeration'
              value_after_temp = enumerations_values_by_custom_fields[custom_field.id].select { |enum| enum[0] == custom_value.value.to_i }.first
              value = value_after_temp.present? ? value_after_temp[1].to_s : ""
              # value = CustomFieldEnumeration.where(id: custom_value.value.to_i).first.to_s # Previously generating N+1 query
            else
              value = custom_value.value
            end
            custom_fields_values.merge!(custom_field.id => value) if value.present?
          end
        end
        custom_fields_values
      end
    end
    values_by_projects
  end

  def enumerations_values_by_custom_fields(custom_fields)
    enumerations_values_by_custom_fields = {}
    custom_fields.each do |custom_field|
      if custom_field.field_format == 'enumeration'
        enumerations_values_by_custom_fields[custom_field.id] = custom_field.enumerations.map { |enum| [enum.id, enum.name] }
      end
    end
    enumerations_values_by_custom_fields
  end

end
