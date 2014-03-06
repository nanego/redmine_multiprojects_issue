require File.dirname(__FILE__) + '/../../helpers/multiprojects_issue_helper'
include MultiprojectsIssueHelper

Deface::Override.new :virtual_path => 'issues/_form',
                     :original     => 'ee65ebb813ba3bbf55bc8dc6279f431dbb405c48',
                     :name         => 'add-multiple-projects-to-issue-form',
                     :insert_after => '.attributes',
                     :partial         => 'issues/select_projects'
