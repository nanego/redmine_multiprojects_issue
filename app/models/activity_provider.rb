class Redmine::Acts::ActivityProvider < ActiveRecord::Base
  self.abstract_class = true
  include RedmineMultiprojectsIssue::ActsAsActivityProvider
end 
# ActiveRecord::Base.send(:include, Redmine::Acts::ActivityProvider)
