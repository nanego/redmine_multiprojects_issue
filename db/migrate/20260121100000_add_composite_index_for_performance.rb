# frozen_string_literal: true

class AddCompositeIndexForPerformance < ActiveRecord::Migration[7.2]
  def change
    add_index :issues_projects, [:project_id, :issue_id],
              name: 'idx_issues_projects_project_issue',
              if_not_exists: true
  end
end
