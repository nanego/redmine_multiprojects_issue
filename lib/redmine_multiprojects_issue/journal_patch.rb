require 'journal'

class RedmineMultiprojectsIssue::JournalPatch < ActiveRecord::Base

  acts_as_activity_provider :type => 'issues_from_current_project_only',
                            :author_key => :user_id,
                            :scope => preload({:issue => :project}, :user).
                                joins({:issue => :project}).
                                joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id").
                                where("#{Journal.table_name}.journalized_type = 'Issue' AND" +
                                          " (#{JournalDetail.table_name}.prop_key = 'status_id' OR #{Journal.table_name}.notes <> '')").distinct,
                            :permission => :view_related_issues_in_secondary_projects

end
