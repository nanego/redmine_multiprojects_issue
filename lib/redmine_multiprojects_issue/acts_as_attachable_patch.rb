module Redmine
  module Acts
    module Attachable
      module InstanceMethods

        unless instance_methods.include?(:attachments_visible_with_multiproject_issues?)
          def attachments_visible_with_multiproject_issues?(user=User.current)
            if self.is_a?(Issue)
              # Check if user is allowed to see attached files in at least one of the impacted projects
              allowed = false
              (self.projects + [self.project]).each do |project|
                allowed = allowed || user.allowed_to?(self.class.attachable_options[:view_permission], project)
                break if allowed
              end
              (respond_to?(:visible?) ? visible?(user) : true) && allowed
            else
              # Process other attachable classes
              attachments_visible_without_multiproject_issues?(user)
            end
          end
          alias_method_chain :attachments_visible?, :multiproject_issues
        end

      end
    end
  end
end
