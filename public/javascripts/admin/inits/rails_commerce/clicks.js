jQuery(document).ready(function(){
  /*
   *Add click function on .gray-destroy items
   *Those items are links to remove their parents (i.e. blocks)
   **/
  $('.gray-destroy').live('click', function(){
    $(this).parent().remove();
    return false;
  });

  $('.red-delete-icon').live('click', function(){
    $(this).parent().hide();
    $($(this).parent()).find('.delete').val(1);
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