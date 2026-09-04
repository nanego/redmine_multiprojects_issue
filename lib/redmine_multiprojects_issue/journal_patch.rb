require_dependency 'journal'

module RedmineMultiprojectsIssue
  module JournalPatch;end
end

class Journal

  acts_as_activity_provider :type => 'issues_from_current_project_only',
                            :author_key => :user_id,
                            :scope => proc {
                              preload({ :issue => :project }, { :issue => :tracker }, :user).
                                joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id").
                                where("#{Journal.table_name}.journalized_type = 'Issue' AND" +
                                        " (#{JournalDetail.table_name}.prop_key = 'status_id' OR #{Journal.table_name}.notes <> '')").distinct
                            }

end
