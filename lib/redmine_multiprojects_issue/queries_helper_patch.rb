require_dependency 'queries_helper'

module QueriesHelper
  include IssuesHelper

  # These methods convert ActiveRecord_Associations to arrays when necessary
  unless instance_methods.include?(:column_content_with_multiprojects_issues)
    def column_content_with_multiprojects_issues(column, issue)
      value = column.value_object(issue)
      if value.kind_of? ActiveRecord::Associations::CollectionProxy
        value = value.to_a
        value.collect {|v| column_value(column, issue, v)}.compact.join(', ').html_safe
      else
        column_content_without_multiprojects_issues(column, issue)
      end
    end
    alias_method_chain :column_content, :multiprojects_issues
  end
  unless instance_methods.include?(:csv_content_with_multiprojects_issues)
    def csv_content_with_multiprojects_issues(column, issue)
      if column.name == :projects && column.value_object(issue).kind_of?(ActiveRecord::Associations::CollectionProxy)
        value = column.value_object(issue).to_a
        value.collect {|v| csv_value(column, issue, v)}.compact.join(', ')
      else
        csv_content_without_multiprojects_issues(column, issue)
      end
    end
    alias_method_chain :csv_content, :multiprojects_issues
  end

end
