require "spec_helper"

describe "JournalMultiprojectsPatch" do

  fixtures :projects, :enabled_modules, :users, :members,
           :member_roles, :roles, :trackers, :issue_statuses,
           :issue_categories, :enumerations, :issues,
           :projects_trackers, :journals, :journal_details

  let(:project) { Project.find(1) }
  let(:manager) { User.find(2) } # Manager on project 1

  def journal_events_for(user)
    Journal.find_events('issues_from_current_project_only', user, nil, nil, project: project).map(&:id)
  end

  def create_issue_with_note(author, attributes = {})
    issue = Issue.create!({ project: project, tracker_id: 1, status_id: 1, priority_id: 4,
                            author: author, subject: "Issue with a note" }.merge(attributes))
    Journal.create!(journalized: issue, user: author, notes: "A note")
  end

  it "lists journals of visible issues from the current project" do
    expect(journal_events_for(manager)).to include(1)
  end

  it "hides journals of private issues from users who may not see them" do
    Role.find(1).update!(issues_visibility: 'default')
    journal = create_issue_with_note(User.find(3), is_private: true)
    expect(journal_events_for(manager)).to_not include(journal.id)
  end

  it "hides journals of other users issues when role issues visibility is set to own" do
    Role.find(1).update!(issues_visibility: 'own')
    journal = create_issue_with_note(User.find(3))
    expect(journal_events_for(manager)).to_not include(journal.id)
    expect(journal_events_for(User.find(3))).to include(journal.id)
  end

  it "hides private notes from users who may not view them" do
    Role.find(1).remove_permission!(:view_private_notes)
    journal = create_issue_with_note(User.find(3))
    journal.update!(private_notes: true)
    expect(journal_events_for(manager)).to_not include(journal.id)
  end

end
