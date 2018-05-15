require_dependency 'queries_helper'

module PluginMultiprojectsIssue
  module QueriesHelperPatch

    # These methods convert ActiveRecord_Associations to arrays when necessary

    def column_content(column, item)
      begin
        value = column.value_object(item)
      rescue
        value = nil
      end
      if column.name == :related_projects && value.present? && value.kind_of?(ActiveRecord::Associations::CollectionProxy)
        value = value.to_a
        value.collect {|v| column_value(column, item, v)}.compact.join(', ').html_safe
      else
        super
      end
    end

    def csv_content(column, issue)
      if column.name == :related_projects && column.value_object(issue).kind_of?(ActiveRecord::Associations::CollectionProxy)
        value = column.value_object(issue).to_a
        value.collect {|v| csv_value(column, issue, v)}.compact.join(', ')
      else
        super
      end
    end

  end
end

QueriesHelper.include IssuesHelper
QueriesHelper.prepend PluginMultiprojectsIssue::QueriesHelperPatch
ActionView::Base.prepend QueriesHelper
IssuesController.prepend QueriesHelper
