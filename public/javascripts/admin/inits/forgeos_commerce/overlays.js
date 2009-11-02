jQuery(document).ready(function(){
  $('#pack-productSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 300,
    width: 1080,
    resizable:'se',
    buttons: {
     Ok: function(){
       add_products_to_pack();
       $('#pack-productSelectDialog').dialog('close');
     }
    },
    open: function(){ $('table-products').dataTableInstance().fnDraw(); }
  });

  $('#add-product').live('click',function(){
    $('#pack-productSelectDialog').dialog('open');
    return false;
  });

});
