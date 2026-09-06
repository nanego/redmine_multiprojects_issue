Deface::Override.new :virtual_path => 'issues/_form',
                     :name         => 'add-multiple-projects-to-issue-form',
                     :insert_after => '.attributes',
                     :partial      => 'issues/select_projects'

Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :name         => 'add-multiple-projects-to-issue-form',
                     :insert_after => '.attributes',
                     :partial      => 'issues/select_projects'
module Issues
    module Form
    end
end