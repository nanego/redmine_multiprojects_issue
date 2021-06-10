module Redmine
  module Acts
    module ActivityProvider
      module InstanceMethods
        module ClassMethods
          # Returns events of type event_type visible by user that occurred between from and to
          def find_events(event_type, user, from, to, options)
            provider_options = activity_provider_options[event_type]
            raise "#{self.name} can not provide #{event_type} events." if provider_options.nil?

            scope = provider_options[:scope]
            if !scope
              scope = self
            elsif scope.respond_to?(:call)
              scope = scope.call
            else
              ActiveSupport::Deprecation.warn "acts_as_activity_provider with implicit :scope option is deprecated. Please pass a scope on the #{self.name} as a proc."
            end

            ## START PATCH
            ## START PATCH
            ## START PATCH

            if event_type == 'issues_from_current_project_only' && options[:project]
              scope = scope.where("issues.project_id = #{options[:project].id}")
            end

            ## END PATCH
            ## END PATCH
            ## END PATCH

            if from && to
              scope = scope.where("#{provider_options[:timestamp]} BETWEEN ? AND ?", from, to)
            end

            if options[:author]
              return [] if provider_options[:author_key].nil?
              scope = scope.where("#{provider_options[:author_key]} = ?", options[:author].id)
            end

            if options[:limit]
              # id and creation time should be in same order in most cases
              scope = scope.reorder("#{table_name}.id DESC").limit(options[:limit])
            end

            if provider_options.has_key?(:permission)
              scope = scope.where(Project.allowed_to_condition(user, provider_options[:permission] || :view_project, options))
            elsif respond_to?(:visible)
              scope = scope.visible(user, options)
            else
              ActiveSupport::Deprecation.warn "acts_as_activity_provider with implicit :permission option is deprecated. Add a visible scope to the #{self.name} model or use explicit :permission option."
              scope = scope.where(Project.allowed_to_condition(user, "view_#{self.name.underscore.pluralize}".to_sym, options))
            end

            scope.to_a
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Redmine::Acts::ActivityProvider)
