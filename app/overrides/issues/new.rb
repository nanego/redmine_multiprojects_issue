Deface::Override.new :virtual_path  => "issues/new",
                     :name          => "add-allowed-projects-div-for-issue",
                     :insert_after  => "div.box.tabular",
                     :partial       => "issues/allowed_target_projects"