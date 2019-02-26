module RedmineMultiprojectsIssue
  module ActivityFetcherPatch
    # Returns an array of events for the given date range
    # sorted in reverse chronological order
    def events(from = nil, to = nil, options = {})
      super.uniq
    end
  end
end
Redmine::Activity::Fetcher.prepend RedmineMultiprojectsIssue::ActivityFetcherPatch
