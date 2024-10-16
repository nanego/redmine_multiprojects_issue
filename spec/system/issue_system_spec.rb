require "spec_helper"
require "active_support/testing/assertions" 

RSpec.describe "/issue/id/edit", type: :system do
  include ActiveSupport::Testing::Assertions

  fixtures :projects, :users, :issues, :workflows, :members, :member_roles, :roles

  def log_user(login, password)
    visit '/my/page'
    expect(current_path).to eq '/login'

    if Redmine::Plugin.installed?(:redmine_scn)
      click_on("ou s'authentifier par login / mot de passe")
    end

    within('#login-form form') do
      fill_in 'username', with: login
      fill_in 'password', with: password
      find('input[name=login]').click
    end
    expect(current_path).to eq '/my/page'
  end

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
      
      find("input[name='commit']").click
      
      expect(page).to have_selector("span", text: "#{Project.find(3).name}")
      expect(page).to have_selector("span", text: "#{Project.find(5).name}")

      # Remake succes validation
      fill_in 'issue_subject', with: 'test'
      find("input[name='commit']").click

      # Related projects 2
      expect(issue.projects.count).to eq(2)
    end
    
  end
end
