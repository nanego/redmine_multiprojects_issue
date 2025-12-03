function update_checked_boxes_counter(){
  const counter_element = $('#selection_counter');
  let counter_value = $("input:checkbox[name='project_ids[]']:checked").length;
  counter_element.html(counter_value);
}

function getSelectedValues(select) {
    var result = [];
    var options = select && select.options;
    var opt;

    for (var i=0, iLen=options.length; i<iLen; i++) {
        opt = options[i];

        if (opt.selected) {
            result.push(opt.value || opt.text);
        }
    }
    return result;
}

function exists(value){
    if( value != undefined && (value > 0 || value.length > 0 || typeof value === "boolean" || typeof value === "object") ){
        return true;
    }else{
        return false;
    }
}

function last_of(array) {
  return array && array.length > 0 ? array[array.length - 1] : null;
}

function insertBefore(newNode, referenceNode) {
  if (referenceNode && referenceNode.parentNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode);
  }
}

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
  $('body').on("change", "input:checkbox[name='project_ids[]']", function(e) {
    update_checked_boxes_counter();
  });
});

(async function() {
  // Wait for Stimulus application to be available
  while (typeof Stimulus === 'undefined') {
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  Stimulus.register("projects-selection", class extends Stimulus.Controller {

    static targets = [ "filters", "filter", "hide_projects_button", "show_projects_button", "counter" ]

    initialize() {
      update_checked_boxes_counter();
    }

    toggle_advanced_selection(event) {
      event.preventDefault();
      this.filtersTarget.classList.toggle('hidden');
    }

    select_filter(event) {
        const container = event.target.nextElementSibling;
        const value = event.target.value?.trim();

        if (!value) {
            container.innerHTML = "";
            return;
        }

        const source = document.getElementById(`select_${value}`);
        container.innerHTML = source ? source.innerHTML : "";
    }

      select_filter_values(event){

      event.preventDefault();
      this.select_none(event);

      const filters_elements = this.filterTargets;
      let filters = {};
      for (let i = 0, len = filters_elements.length; i < len; i++) {
        const filter_element = filters_elements[i];
        const select_filters_element = filter_element.firstElementChild;
        const field = select_filters_element.value;
        let values = getSelectedValues(select_filters_element.nextElementSibling);
        if(exists(field)){
          filters[field] = values;
        }
      }
      this.select_from_filters(filters);
    }

    select_from_filters(filters) {
      const _this = this;
      let checked_boxes_per_field = {};

      // Union of results for each filter
      Object.keys(filters).map(function(field, index) {
        checked_boxes_per_field[field] = [];
        let values = filters[field];
        for (let i = 0, len = values.length; i < len; i++) {
          checked_boxes_per_field[field] = [...new Set([...checked_boxes_per_field[field], ..._this.checked_boxes(field, values[i])])];
        }
      });

      // Intersection of results between filters
      let final_checked_boxes;
      Object.keys(checked_boxes_per_field).map(function(field, index) {
        if(index==0){
          final_checked_boxes = checked_boxes_per_field[field];
        }else{
          final_checked_boxes = final_checked_boxes.filter((n) => checked_boxes_per_field[field].includes(n))
        }
      });

      for (var i = 0, len = final_checked_boxes.length; i < len; i++) {
        $('.nested_project_'+final_checked_boxes[i]).prop("checked","checked");
      }

      update_checked_boxes_counter();
      this.show_all_projects();
    }

    checked_boxes(field, value){
      let checked_boxes = [];
      if(exists(value)){
        //build a selector ; as we now accept "array" values, we must match foo OR *,foo OR *,foo,* OR foo,*...
        let selectors, selector;
        selectors = [ "='"+value+"'", "^='"+value+",'", "$=',"+value+"'", "*=',"+value+",'" ];
        selector = $.map(selectors, function(e) {
          return "input:checkbox[name='project_ids[]']:checkbox[data-"+field+e+"]"
        }).join(", ");
        //for each matching value, select the checkbox
        $(selector).each(function() {
          checked_boxes.push($(this).val());
        });
      }
      return checked_boxes;
    }

    select_all(event){
      event.preventDefault();
      $("input:checkbox[name='project_ids[]']").each(function()
      {
        $(this).prop("checked","checked") ;
      });
      update_checked_boxes_counter();
      this.show_all_projects();
    }

    select_none(event){
      event.preventDefault();
      $("input:checkbox[name='project_ids[]']:checked:not(.inactive)").each(function()
      {
        $(this).prop("checked",false) ;
      });
      update_checked_boxes_counter();
      this.show_all_projects();
    }

    add_filter(event){
      event.preventDefault();
      const last_filter = last_of(this.filterTargets);
      let new_filter = document.createElement('div');
      new_filter.dataset.projectsSelectionTarget = "filter";
      new_filter.innerHTML = last_filter.innerHTML;
      new_filter.querySelector("#select_values").innerHTML = "";
      insertBefore(new_filter, event.target);
    }

    remove_filter(event){
      event.preventDefault();
      event.target.parentNode.outerHTML='';
      this.select_filter_values(event);
    }

    hide_non_selected_projects(event){
      event.preventDefault();
      $("input:checkbox[name='project_ids[]']:not(:checked)").each(function()
      {
        $(this).parent().hide();
      });
      this.show_projects_buttonTarget.style.display = 'inline-block';
      this.hide_projects_buttonTarget.style.display = 'none';
    }

    hide_by_name(event) {
        this.show_all_projects(event);

        const value = event.target.value?.trim().toLowerCase();
        if (!value) return;

        $("#project_nested_list input[name='project_ids[]']").each(function () {
            const name = $(this).data("name")?.toLowerCase() || "";
            $(this).parent().toggle(name.includes(value));
        });
    }

    show_all_projects(event){
      if(event){event.preventDefault()}
      $("input:checkbox[name='project_ids[]']").each(function()
      {
        $(this).parent().show();
      });
      this.show_projects_buttonTarget.style.display = 'none';
      this.hide_projects_buttonTarget.style.display = 'inline-block';
    }

  })
})();
