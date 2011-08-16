function add_item_on_add_click() {
  if (typeof(false_id) == 'undefined') false_id = -1;
  var object_name = jQuery('.sortable-choices').parents('form').data('object_name');
  var new_choice = '<li class="block-container">';
  new_choice += '<span class="block-type"> <span class="handler"> <span class="inner" /> </span> </span> </span>';
  new_choice += '<span class="block-image"><img src="/images/admin/no-image_50x50.png" id="item_'+false_id+'_image" alt="No-image_50x50"><input type="hidden" value="" name="'+object_name+'[attribute_values_attributes]['+false_id+'][picture_ids]" id="attribute_values_attributes_'+false_id+'_picture_ids"><a id="change_picture_item_'+false_id+'" class="big-icons edit change-picture" href="#"></a></span>';
  new_choice += '<span class="block-name"> <input type="text" id="attribute_values_attributes_'+false_id+'" size="30" name ="'+object_name+'[attribute_values_attributes]['+false_id+'][value]" /> ';
  new_choice += '<input type="hidden" class="delete" name="'+object_name+'[attribute_values_attributes]['+false_id+'][_destroy]" />';
  new_choice += '<input type="hidden" name="'+object_name+'[attribute_values_attributes]['+false_id+'][position]" value=""/>';
  new_choice += '</span> <span class="small-icons red-delete-icon" />';
  new_choice += '</span> <span class="small-icons green-add-icon" />';
  new_choice += '</li>';

  false_id--;
  jQuery('.sortable-choices').append(new_choice);
  return false;
}

