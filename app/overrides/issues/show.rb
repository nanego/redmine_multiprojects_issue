Deface::Override.new :virtual_path => 'issues/show',
                     :original     => 'ee65ebb813ba3bbf55bc8dc6279f431dbb405c48',
                     :name         => 'show-projects-in-issue-description',
                     :insert_after => '.attributes',
                     :partial         => 'issues/show_projects'
module Issues
    module Show
    end
end