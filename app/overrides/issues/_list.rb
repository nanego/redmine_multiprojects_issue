Deface::Override.new :virtual_path => 'issues/_list',
                     :name         => 'disable_project_link_if_current_user_cannot_open_it',
                     :insert_after => 'table.list.issues tbody tr',
                     :partial      => 'issues/link_to_project'
