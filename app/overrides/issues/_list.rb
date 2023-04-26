Deface::Override.new :virtual_path => 'issues/_list',
                     :original     => 'ee65ebb813ba3bbf55bc8dc6279f431dbb405c48',
                     :name         => 'disable_project_link_if_current_user_cannot_open_it',
                     :insert_after => 'table.list.issues tbody tr',
                     :partial      => 'issues/link_to_project'
module Issues
    module List
    end
end