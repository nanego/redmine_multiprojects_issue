require_dependency 'project'

class Project

  self.singleton_class.send(:alias_method, :core_allowed_to_condition, :allowed_to_condition)

  def self.allowed_to_condition(user, permission, options={})

    # TODO Improve the request to limit it according to permissions
    "(#{core_allowed_to_condition(user, permission, options)} OR #{Project.table_name}.id IN (SELECT project_id FROM issues_projects GROUP BY project_id))"

  end

end
