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
    open: function(e,ui){
      eval(jQuery('#table-products').data('dataTables_init_function')+'()');
    }
  });

  jQuery('#add-product').live('click',function(e){
    e.preventDefault();
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
    open: function(){ eval(jQuery('#table-redirections').data('dataTables_init_function')+'()');}
  });

  jQuery('#add-redirection-product').live('click',function(e){
    e.preventDefault();
    jQuery('#redirection-productSelectDialog').dialog('open');
    return false;
  });
});
