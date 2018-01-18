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

      event.preventDefault();
      this.select_none(event);

      const filters_elements = this.targets.findAll("filter");
      let filters = {};
      for (var i = 0, len = filters_elements.length; i < len; i++) {
        const filter_element = filters_elements[i];
        const select_filters_element = filter_element.firstElementChild;
        const field = select_filters_element.value;
        const values = getSelectedValues(select_filters_element.nextElementSibling);

        filters[field] = values;
      }
      this.select_from_filters(filters);
    }

    select_from_filters(filters) {
      console.log(filters);
      const _this = this;
      let checked_boxes_per_field = [];
      Object.keys(filters).map(function(field, index) {
        var values = filters[field];
        for (var i = 0, len = values.length; i < len; i++) {
          checked_boxes_per_field.push(_this.checked_boxes(field, values[i]));
        }
      });
      log('checked_boxes_per_field lenght', checked_boxes_per_field.length);
      let final_checked_boxes = checked_boxes_per_field[0];
      for (var i = 1, len = checked_boxes_per_field.length; i < len; i++) {
        final_checked_boxes = final_checked_boxes.filter((n) => checked_boxes_per_field[i].includes(n))
      }

      console.log(final_checked_boxes);

      log('final_checked_boxes lenght', final_checked_boxes.length);

      for (var i = 0, len = final_checked_boxes.length; i < len; i++) {
        $('.nested_project_'+final_checked_boxes[i]).prop("checked","checked");
      }
    }

    checked_boxes(field, value){
      let checked_boxes = [];
      if(exists(value)){
        //build a selector ; as we now accept "array" values, we must match foo OR *,foo OR *,foo,* OR foo,*...
        var selectors, selector;
        selectors = [ "='"+value+"'", "^='"+value+",'", "$=',"+value+"'", "*=',"+value+",'" ];
        selector = $.map(selectors, function(e) {
          return "input:checkbox[name='project_ids[]']:checkbox[data-"+field+e+"]"
        }).join(", ");
        //for each matching value, select the checkbox
        $(selector).each(function() {
          checked_boxes.push($(this).val());
        });
      }
      log('011 checked_boxes lenght', checked_boxes.length);
      console.log(checked_boxes);
      return checked_boxes;
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

    add_filter(event){
      event.preventDefault();
      const last_filter = last_of(this.targets.findAll("filter"));
      let new_filter = document.createElement('div');
      new_filter.dataset.target = "projects-selection.filter";
      new_filter.innerHTML = last_filter.innerHTML;
      new_filter.querySelector("#select_values").innerHTML = "";
      insertBefore(new_filter, event.target);
    }

    remove_filter(event){
      event.preventDefault();
      event.target.parentNode.outerHTML='';
      this.select_filter_values(event);
    }

    get filters(){
      return this.targets.find("filters");
    }

  })
})();
