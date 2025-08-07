Deface::Override.new :virtual_path => 'issues/_form',
                     :original     => 'ee65ebb813ba3bbf55bc8dc6279f431dbb405c48',
                     :name         => 'add-multiple-projects-to-issue-form',
                     :insert_after => '.attributes',
                     :partial      => 'issues/select_projects'

Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :original     => 'ee65ebb813ba3bbf55bc8dc6279f431dbb405c48',
                     :name         => 'add-multiple-projects-to-issue-form',
                     :insert_after => '.attributes',
                     :partial      => 'issues/select_projects'
module Issues
    module Form
    end
end