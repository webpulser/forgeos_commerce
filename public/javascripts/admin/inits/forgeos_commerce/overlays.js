jQuery(document).ready(function(){
  $('#pack-productSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 300,
    width: 1080,
    resizable:'se',
    buttons: {
     Ok: function(){
       current_table_index = 0;
       add_products_to_pack();
       $('#pack-productSelectDialog').dialog('close');
     }
    }
  });

  $('#add-product').live('click',function(){
    $('#pack-productSelectDialog').dialog('open');
    return false;
  });

});
