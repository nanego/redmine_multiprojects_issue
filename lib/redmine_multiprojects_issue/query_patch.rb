require_dependency 'query'

class QueryAssociationColumn < QueryColumn

  def value_object(object)
    if assoc = object.send(@association)
      assoc.send @attribute
    end
  end

end

class QueryAssociationCustomFieldColumn < QueryCustomFieldColumn

  def value_object(object)
    if assoc = object.send(@association)
      super(assoc)
    end
  end

end

module RedmineMultiprojectsIssue
  module QueryPatch;end
end
