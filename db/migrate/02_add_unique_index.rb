class AddUniqueIndex < ActiveRecord::Migration
  def change
    add_index :issues_projects, [:issue_id, :project_id], :unique => true
  end
end
