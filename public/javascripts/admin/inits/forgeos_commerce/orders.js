jQuery(document).ready(function(){
  jQuery('.add-order-detail').live('click',function(e){
    e.preventDefault();
    jQuery('#productSelectDialog').dialog('open');
    return false;
  });

  jQuery('#productSelectDialog').dialog({
     autoOpen:false,
     modal:true,
     minHeight: 380,
     width: 800,
     resizable:'se',
     buttons: {
       Ok: function(){
         dataTableSelectRows('#table-products', function(current_table, indexes) {
           for(var i=0; i<indexes.length; i++){
             var row = current_table.fnGetData(indexes[i]);
             var id = row.slice(-4,-3);
             var name = row.slice(-3,-2)[0];
             var sku = row.slice(-2,-1);
             var price = row.slice(-1);
             var price_with_currency = row.slice(3,4);
             var img = jquery_obj_to_str(jQuery(row.slice(0, 1)[0]).find('img'));

             add_product_to_order_detail(id, name, sku, price, price_with_currency, img);
           }
           jQuery('#transporter_rebuild').val(1);
           update_order_total();
         });
         jQuery('#productSelectDialog').dialog('close');
       }
     },
     open: function(e,ui){
       eval(jQuery('#table-products').data('dataTables_init_function')+'()');
     }
  });

  // update voucher value and hide/show
  jQuery('#voucher').bind('change', function() {

    // update display value and hidden field tag
    jQuery('.voucher_value').html(jQuery(this).val());
    jQuery('#order_voucher').val(jQuery(this).val());

    // show/hide voucher value
    if (jQuery(this).val() == '')
      jQuery('.voucher').hide();
    else
      jQuery('.voucher').show();
    update_order_total();
  });

  // update order shipping name and value
  jQuery('#order_shipping').bind('change', function() {
    var name = jQuery(this).find("OPTION:selected").text();
    var price = jQuery(this).val();

    if (price != ''){
      jQuery('.order_shipping_name').html(name);
      jQuery('#order_order_shipping_attributes_name').val(name);
      jQuery('.order_shipping_price').html(price);
      jQuery('#order_order_shipping_attributes_price').val(price);
      update_order_total();
    }
  });

  // update order status in index
  jQuery('.order-change-status').live('change', function() {
    var state = jQuery(this).val();
    var order_id = get_rails_element_id(this);
    jQuery.ajax({
      "url": '/admin/orders/'+order_id,
      "complete": display_notifications,
      "data": {
        "authenticity_token": encodeURIComponent(window._forgeos_js_vars.token),
        "order[aasm_current_state_with_event_firing]": state
      },
      "dataType": 'text',
      "type": 'put'
    });
  });
});
