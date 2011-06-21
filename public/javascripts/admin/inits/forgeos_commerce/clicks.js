jQuery(document).ready(function(){
  /*
   *Add click function on .gray-destroy items
   *Those items are links to remove their parents (i.e. blocks)
   **/
  jQuery('.red-delete-icon').live('click', function(){
    var block = jQuery(this).parents(':first');
    if (parseInt(get_rails_element_id(block.find('input:first'))) < 0) {
      block.remove();
    } else {
      block.hide();
      block.find('.delete').val(1);
    }
    return false;
  });

  jQuery('.gray-destroy-tattribute').live('click', function(){
    jQuery(this).parents('li').remove();
    return false;
  });

  jQuery('.add-link.choice,.block-container .green-add-icon').live('click', add_item_on_add_click);
});
