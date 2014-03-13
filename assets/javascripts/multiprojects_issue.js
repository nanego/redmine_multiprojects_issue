var projectsSelectionAlreadyLoaded = false
$(document).ready(function(){
    $('#all_attributes').on("click", "#loadModalProjectsSelection", function(e) {
        if(projectsSelectionAlreadyLoaded == true){
            showModal('ajax-modal', '1000px');
            $('#button_apply_projects').focus();
            return false;
        }
    });

    $('.details').on("click", ".show_journal_details", function(e) {
        e.preventDefault();
        $('.journal_projects_details[data-detail-id='+$(this).data('detail-id')+']').show();
        $('.show_journal_details[data-detail-id='+$(this).data('detail-id')+']').hide();
    });
});
