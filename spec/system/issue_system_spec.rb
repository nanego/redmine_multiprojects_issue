require "spec_helper"
require "active_support/testing/assertions" 

RSpec.describe "/issue/id/edit", type: :system do
  include ActiveSupport::Testing::Assertions

  fixtures :projects, :users, :issues, :workflows, :members, :member_roles, :roles

  before do
    log_user('admin', 'admin')
  end

  describe "Fail validation of issue" do
    let!(:issue) { Issue.first }

    it "Should keep the selected projects" do
      # Related projects 0
      expect(issue.projects.count).to eq(0)

      visit edit_issue_path( id: issue.id)
      # open  Related projects modal
      find('#loadModalProjectsSelection').click

      within '#ajax-modal' do
        # select projects with id  3 , 5
        find("input[value='5']").click
        find("input[value='3']").click

        find("input[id='button_apply_projects']").click
      end
      
      # Make fail validation
      fill_in 'issue_subject', with: ''
      find("input[id='edit-submit']").click
      
      expect(page).to have_selector("span", text: "#{Project.find(3).name}")
      expect(page).to have_selector("span", text: "#{Project.find(5).name}")

      # Remake succes validation
      fill_in 'issue_subject', with: 'test'
      find("input[id='edit-submit']").click

      # Related projects 2
      expect(issue.projects.count).to eq(2)
    end
    
  end
end
