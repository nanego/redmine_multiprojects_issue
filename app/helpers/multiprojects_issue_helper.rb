module MultiprojectsIssueHelper

  def custom_values_by_project_ids(projects, custom_fields)
    return {} if projects.empty? || custom_fields.empty?

    project_ids = projects.map { |p| p[0] }
    enumerations_values = enumerations_values_by_custom_fields(custom_fields)
    invalidation_cache_key = Project.maximum(:updated_on).to_i
    cache_key = ['multiprojects-plugin-custom_values_by_projects',
                 custom_fields.map(&:id).join('-'),
                 invalidation_cache_key].join('-')

    all_values = Rails.cache.fetch(cache_key) do
      map = {}
      CustomValue
        .where(customized_type: 'Project', custom_field_id: custom_fields.map(&:id))
        .each do |cv|
          next if cv.value.blank?
          cf = custom_fields.find { |f| f.id == cv.custom_field_id }
          next unless cf
          value = if cf.field_format == 'enumeration'
            enumerations_values[cf.id][cv.value.to_i]
          else
            cv.value
          end
          next unless value.present?
          map[cv.customized_id] ||= {}
          map[cv.customized_id][cv.custom_field_id] = value
        end
      map
    end

    project_ids.each_with_object({}) { |pid, h| h[pid] = all_values[pid] || {} }
  end

  def enumerations_values_by_custom_fields(custom_fields)
    enumerations_values_by_custom_fields = {}
    custom_fields.each do |custom_field|
      if custom_field.field_format == 'enumeration'
        enumerations_values_by_custom_fields[custom_field.id] ||= {}
        custom_field.enumerations.each do |enum|
          enumerations_values_by_custom_fields[custom_field.id][enum.id] = enum.name
        end
      end
    end
    enumerations_values_by_custom_fields
  end

end
