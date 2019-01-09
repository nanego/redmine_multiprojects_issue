class AddUniqueIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :issues_projects, [:issue_id, :project_id], :unique => true
  end
end
