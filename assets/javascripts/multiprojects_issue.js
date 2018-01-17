$(document).ready(function(){
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

(function() {
  stimulus_application.register("projects-selection", class extends Stimulus.Controller {
    toggle_advanced_selection(event) {
      event.preventDefault();
      this.filters.classList.toggle('hidden');
    }

    select_filter(event){
      const select_values_element = event.target.nextElementSibling;
      const target = "select_for_"+event.target.value;
      const targeted_select = this.targets.find(target);
      if (exists(event.target.value)){
        select_values_element.innerHTML = targeted_select.innerHTML;
      }else{
        select_values_element.innerHTML = "";
      }
    }

    select_filter_values(event){
      const select_filters_element = event.target.previousElementSibling;
      const field = select_filters_element.value;
      const value = event.target.value;
      if(isInteger(field)){
        this.select_from_custom_field(event, field, value);
      }
    }

    select_from_custom_field(event, id, value) {
      event.preventDefault();
      this.select_none(event);
      if(exists(value)){
        //build a selector ; as we now accept "array" values, we must match foo OR *,foo OR *,foo,* OR foo,*...
        var selectors, selector;
        selectors = [ "='"+value+"'", "^='"+value+",'", "$=',"+value+"'", "*=',"+value+",'" ];
        selector = $.map(selectors, function(e) {
          return "input:checkbox[name='project_ids[]']:checkbox[data-"+id+e+"]"
        }).join(", ");
        //for each matching value, select the checkbox
        $(selector).each(function() {
          $(this).prop("checked","checked") ;
        });
      }

    }

    select_all(event){
      event.preventDefault();
      $("input:checkbox[name='project_ids[]']").each(function()
      {
        $(this).prop("checked","checked") ;
      });
    }

    select_none(event){
      event.preventDefault();
      $("input:checkbox[name='project_ids[]']:checked:not(.inactive)").each(function()
      {
        $(this).prop("checked",false) ;
      })
    }

    get filters(){
      return this.targets.find("filters");
    }

  })
})();
