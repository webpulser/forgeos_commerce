function node_to_string(node){
  node.wrap('<div id="clone_wrapper"></div>');
  var output = $('#clone_wrapper').html();
  $('#clone_wrapper').remove();
  return output;
}

function add_product_to_order_detail(id, name, sku, price, price_with_currency, img){
  // add order detail to datatable
  var current_table = $('#table-order-details').dataTableInstance();
  var remove_link = '<a id="order_detail_'+false_id+'" class="small-icons destroy-link" onclick="remove_order_detail($(this));; return false;" href="#"/>';


  // add hidden field for new order detail and update total
  var new_order_detail = $('<div id="order_detail_' + false_id + '">').html($('#empty_order_detail').html().replace(/EMPTY_ID/g, false_id));
  var base_field_id = '#order_order_details_attributes_'+false_id+'_';

  $(new_order_detail).find(base_field_id+'product_id').val(id);
  $(new_order_detail).find(base_field_id+'name').val(name);
  $(new_order_detail).find(base_field_id+'price').val(price);
  $(new_order_detail).find(base_field_id+'sku').val(sku);
  $('#order_details').append(new_order_detail);

  name = name + node_to_string($(new_order_detail).find(base_field_id+'product_id')) + node_to_string($(new_order_detail).find(base_field_id+'name'));
  sku = sku + node_to_string($(new_order_detail).find(base_field_id+'sku'));
  price = price + node_to_string($(new_order_detail).find(base_field_id+'price'));

  current_table.fnAddData([img,name,sku,price,'1',price_with_currency,remove_link]);
  //update_order_total();
  false_id--;
}

// hide order detail container and set order detail delete value to 1
function remove_order_detail(destroy_link){
  var current_table = $('#table-order-details').dataTableInstance();
  var base_field_id = '#order_order_details_attributes_'+get_rails_element_id(destroy_link)+'_';
  var detail_id = $(base_field_id+'id').val();

  // remove row
  current_table.fnDeleteRow(
      current_table.fnGetPosition($(destroy_link).parents('tr:first')[0])
  );

  // set order detail deleted
  $(base_field_id+'_destroy').val(1);

  // remove special offer and voucher discount detail
  $('.special_order_detail_'+ detail_id).remove();
  $('.voucher_order_detail_'+ detail_id).remove();

  update_order_total();
}

function update_order_total(){
  var form = $('form.edit_order');
  var url = $(form).attr('action') + '/total';

  $.ajax({
    url: url,
    data: $(form).serialize(),
    success:function(request){
      $('span.order-price').text(request.total);
      $('span.order-total').text(request.total);
      $('span.order-subtotal').text(request.subtotal);
      $('#transporter_rebuild').val(0);
      if (request.rebuild_transporter == 1){
        // remove old transporters
        $('#order_shipping').children().remove();
      
        // remove custom select
        $('.delivery-method').removeClass('enhanced');
        $('.delivery-method').children('.dropdown').remove();
      
        // add new available transporters
        for (var i=0; i<request.available_transporters.length; i++){
	      var transporter_rule = request.available_transporters[i].transporter_rule;
	      $('#order_shipping').append('<option value="'+transporter_rule.variables+'">'+transporter_rule.name+'</options>');
	    }
	  }
      //$('span.order-taxes').text(request.taxes);
      
      // rebuild custom select
      InitCustomSelects();
    },
    dataType:'json',
    type:'post'
  });
}
