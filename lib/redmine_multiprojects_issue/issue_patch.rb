require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects

end
