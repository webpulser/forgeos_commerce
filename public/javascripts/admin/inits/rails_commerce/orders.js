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
         var current_table = oTables[current_table_index];
         indexes = current_table.fnGetSelectedIndexes();

         for(var i=0; i<indexes.length; i++){
           id = current_table.fnGetData(indexes[i]).slice(-4,-3);
           name = current_table.fnGetData(indexes[i]).slice(-3,-2)[0];
           sku = current_table.fnGetData(indexes[i]).slice(-2,-1);
           price = current_table.fnGetData(indexes[i]).slice(-1);
           price_with_currency = current_table.fnGetData(indexes[i]).slice(3,4);
           img = current_table.fnGetData(indexes[i]).slice(0, 1)[0];
           img = jquery_obj_to_str($(img).find('img'));

           current_table_index = 1;
           add_product_to_order_detail(id, name, sku, price, price_with_currency, img);
         }
         $(current_table.fnGetSelectedNodes()).toggleClass('row_selected');
         $('#productSelectDialog').dialog('close');
       }
     },
     open: function(){
        current_table_index = 0;
     }
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