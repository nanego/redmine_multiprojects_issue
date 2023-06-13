Deface::Override.new :virtual_path  => "issues/edit",
                     :name          => "add-allowed-projects-div-for-issue",
                     :insert_after  => "h2:first",
                     :partial       => "issues/allowed_target_projects"