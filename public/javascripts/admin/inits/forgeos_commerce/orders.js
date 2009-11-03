jQuery(document).ready(function(){
  $('.add-order-detail').live('click',function(){
    $('#productSelectDialog').dialog('open');
    return false;
  });

  $('#productSelectDialog').dialog({
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
             var img = jquery_obj_to_str($(row.slice(0, 1)[0]).find('img'));

             add_product_to_order_detail(id, name, sku, price, price_with_currency, img);
           }
           $('#transporter_rebuild').val(1);
           update_order_total();
         });
         $('#productSelectDialog').dialog('close');
       }
     },
     open: function(){ $('#table-products').dataTableInstance().fnDraw(); }
  });

  // update voucher value and hide/show
  $('#voucher').bind('change', function() {

    // update display value and hidden field tag
    $('.voucher_value').html($(this).val());
    $('#order_voucher').val($(this).val());

    // show/hide voucher value
    if ($(this).val() == '')
      $('.voucher').hide();
    else
      $('.voucher').show();
    update_order_total();
  });

  // update order shipping name and value
  $('#order_shipping').bind('change', function() {
    var name = $(this).find("OPTION:selected").text();
    var price = $(this).val();

    if (price != ''){
      $('.order_shipping_name').html(name);
      $('#order_order_shipping_attributes_name').val(name);
      $('.order_shipping_price').html(price);
      $('#order_order_shipping_attributes_price').val(price);
      update_order_total();
    }
  });

  // update order status in index
  $('.order-change-status').live('change', function() {
    var state = $(this).val();
    var order_id = get_rails_element_id(this);
    $.ajax({
      url: '/admin/orders/'+order_id,
      complete: display_notifications,
      data: { authenticity_token: encodeURIComponent(AUTH_TOKEN), 'order[status]': state },
      dataType:'text',
      type:'put'
    });
  });
});
