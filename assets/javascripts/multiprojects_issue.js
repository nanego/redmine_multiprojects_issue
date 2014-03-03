var projectsSelectionAlreadyLoaded = false
$(document).ready(function(){
    $('#all_attributes').on("click", "#loadModalProjectsSelection", function(e) {
        if(projectsSelectionAlreadyLoaded == true){
            showModal('ajax-modal', '1000px');
            $('#button_apply_projects').focus();
            return false;
        }
    });
});