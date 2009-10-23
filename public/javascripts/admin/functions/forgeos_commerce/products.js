/*
 *Show/Hide the stock's tool-tip
 **/
function tool_tip(){
  $(".tool-tip-me").mouseover(function(){
    $(this).children('.tool-tip-content').show();
  });
   $(".tool-tip-me").mouseout(function(){
    $(this).children('.tool-tip-content').hide();
  });
}


function add_product_to_order_detail(id, name, sku, price, price_with_currency, img){
  // add order detail to datatable
  var current_table = oTables[current_table_index];
  var remove_link = '<a id="order_detail_'+false_id+'" class="small-icons destroy-link" onclick="remove_order_detail($(this));; return false;" href="#"/>';

  current_table.fnAddData([img,name,sku,price,'1',price_with_currency,remove_link]);

  // add hidden field for new order detail and update total
  var new_order_detail = $('<div id="order_detail_' + false_id + '">').html($('#empty_order_detail').html().replace(/EMPTY_ID/g, false_id));
  var base_field_id = '#order_orders_details_attributes_'+false_id+'_';

  $(new_order_detail).find(base_field_id+'product_id').val(id);
  $(new_order_detail).find(base_field_id+'name').val(name);
  $(new_order_detail).find(base_field_id+'price').val(price);
  $(new_order_detail).find(base_field_id+'sku').val(sku);
  $('#order_details').append(new_order_detail);

  update_order_total();
  false_id--;
}

function check_product_first_image(){
  $('#product-images .sortable li:eq(0)').addClass('first-image');
}

function add_products_to_pack(){
  var current_table = $('#table-products').dataTableInstance();
  indexes = current_table.fnGetSelectedIndexes();
  for(var i=0; i<indexes.length; i++){
    name = current_table.fnGetData(indexes[i]).slice(-3,-2);
    id = current_table.fnGetData(indexes[i]).slice(-4,-3);
    price = current_table.fnGetData(indexes[i]).slice(-1);
    sku = current_table.fnGetData(indexes[i]).slice(-2,-1);

    $('#pack-products').append('<div class="block-container"><input type="hidden" name="pack[product_ids][]" value="'+id+'" /><span class="block-type"><span class="handler"><span class="inner">&nbsp;</span></span>'+sku+'</span><span class="block-name">'+name+'<span class="file-size"> - '+price+'</span></span><a href="#" class="big-icons gray-destroy"></a></div>');
  }
  $(current_table.fnGetSelectedNodes()).toggleClass('row_selected');
}
