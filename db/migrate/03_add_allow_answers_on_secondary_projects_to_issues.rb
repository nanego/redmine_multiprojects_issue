class AddAllowAnswersOnSecondaryProjectsToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :answers_on_secondary_projects, :boolean,
               :default => true, :null => false
  end
end
