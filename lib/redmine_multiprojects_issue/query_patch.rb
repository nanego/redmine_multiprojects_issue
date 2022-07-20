require_dependency 'query'

module RedmineMultiprojectsIssue
  module QueryPatch
    module QueryAssociationColumnPatch
      def value_object(object)
        if assoc = object.send(@association)
          assoc.send @attribute
        end
      end
    end

    module QueryAssociationCustomFieldColumnPatch
      def value_object(object)
        if assoc = object.send(@association)
          super(assoc)
        end
      end
    end
  end
end

QueryAssociationColumn.prepend RedmineMultiprojectsIssue::QueryPatch::QueryAssociationColumnPatch
QueryCustomFieldColumn.prepend RedmineMultiprojectsIssue::QueryPatch::QueryAssociationCustomFieldColumnPatch
