jQuery(document).ready(function(){
  /*
   *Add click function on .gray-destroy items
   *Those items are links to remove their parents (i.e. blocks)
   **/
  $('.red-delete-icon').live('click', function(){
    var block = $(this).parents(':first');
    if (parseInt(get_rails_element_id(block.find('input:first'))) < 0) {
      block.remove();
    } else {
      block.hide();
      block.find('.delete').val(1);
    }
    return false;
  });

  $('.gray-destroy-tattribute').live('click', function(){
    $(this).parents('li').remove();
    return false;
  });

  /*
   *Add click function on .tags a.big-icons items
   *Those items are links to remove elements (i.e. tags)
   **/
  $('.tags a.big-icons').live('click', function(){
    $(this).remove();
    return false;
  });

  $('.add-choice,.block-container .green-add-icon').live('click', add_item_on_add_click);
});
