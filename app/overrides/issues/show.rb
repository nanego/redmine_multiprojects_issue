Deface::Override.new :virtual_path => 'issues/show',
                     :name         => 'show-projects-in-issue-description',
                     :insert_after => '.attributes',
                     :partial      => 'issues/show_projects'