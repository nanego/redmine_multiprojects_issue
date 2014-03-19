var projectsSelectionAlreadyLoaded = false
$(document).ready(function(){
    // To load project selection modal
    $('#all_attributes').on("click", "#loadModalProjectsSelection", function(e) {
        if(projectsSelectionAlreadyLoaded == true){
            showModal('ajax-modal', '1000px');
            $('#button_apply_projects').focus();
            return false;
        }
    });

    // To deal with journal details
    $('.details').on("click", ".show_journal_details", function(e) {
        e.preventDefault();
        $('.journal_projects_details[data-detail-id='+$(this).data('detail-id')+']').show();
        $('.hide_journal_details[data-detail-id='+$(this).data('detail-id')+']').show();
        $(this).hide();
    });
    $('.details').on("click", ".hide_journal_details", function(e) {
        e.preventDefault();
        $('.journal_projects_details[data-detail-id='+$(this).data('detail-id')+']').hide();
        $('.show_journal_details[data-detail-id='+$(this).data('detail-id')+']').show();
        $(this).hide();
    });

});
