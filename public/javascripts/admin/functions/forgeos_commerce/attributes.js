function add_item_on_add_click() {
  false_id = -1;
  var new_choice = '<li class="block-container">';
  new_choice += '<span class="block-type"> <span class="handler"> <span class="inner" /> </span> </span> </span>';
  new_choice += '<span class="block-name"> <input type="text" id="attribute_values_attributes_'+false_id+'" size="30" name ="'+object_name+'[attribute_values_attributes]['+false_id+'][name]" /> ';
  new_choice += '<input type="hidden" class="delete" name="'+object_name+'[attribute_values_attributes]['+false_id+'][_delete]" />';
  new_choice += '<input type="hidden" name="'+object_name+'[attribute_values_attributes]['+false_id+'][position]" value=""/>';
  new_choice += '</span> <span class="small-icons red-delete-icon" />';
  new_choice += '</span> <span class="small-icons green-add-icon" />';
  new_choice += '</li>';

  false_id--;
  $('.sortable-choices').append(new_choice);
  return false;
}
