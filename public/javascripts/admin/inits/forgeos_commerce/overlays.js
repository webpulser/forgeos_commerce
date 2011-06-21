jQuery(document).ready(function(){
  jQuery('#pack-productSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 300,
    width: 1080,
    resizable:'se',
    buttons: {
     Ok: function(){
       add_products_to_pack();
       jQuery('#pack-productSelectDialog').dialog('close');
     }
    },
    open: function(){ jQuery('table-products').dataTableInstance().fnDraw(); }
  });

  jQuery('#add-product').live('click',function(){
    jQuery('#pack-productSelectDialog').dialog('open');
    return false;
  });

  jQuery('#redirection-productSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 300,
    width: 1080,
    resizable:'se',
    buttons: {
     Ok: function(){
       change_redirection_product();
       jQuery('#redirection-productSelectDialog').dialog('close');
     }
    },
    open: function(){ jQuery('table-products').dataTableInstance().fnDraw(); }
  });

  jQuery('#add-redirection-product').live('click',function(){
    jQuery('#redirection-productSelectDialog').dialog('open');
    return false;
  });


});
