function node_to_string(node){
  node.wrap('<div id="clone_wrapper"></div>');
  var output = jQuery('#clone_wrapper').html();
  jQuery('#clone_wrapper').remove();
  return output;
}

function add_product_to_order_detail(id, name, sku, price, price_with_currency, img){
  // add order detail to datatable
  var current_table = jQuery('#table-order-details').dataTableInstance();
  var remove_link = '<a id="order_detail_'+false_id+'" class="small-icons destroy-link" onclick="remove_order_detail(jQuery(this));; return false;" href="#"/>';


  // add hidden field for new order detail and update total
  var new_order_detail = jQuery('<div id="order_detail_' + false_id + '">').html(jQuery('#empty_order_detail').html().replace(/EMPTY_ID/g, false_id));
  var base_field_id = '#order_order_details_attributes_'+false_id+'_';

  jQuery(new_order_detail).find(base_field_id+'product_id').val(id);
  jQuery(new_order_detail).find(base_field_id+'name').val(name);
  jQuery(new_order_detail).find(base_field_id+'price').val(price);
  jQuery(new_order_detail).find(base_field_id+'sku').val(sku);
  jQuery('#order_details').append(new_order_detail);

  name = name + node_to_string(jQuery(new_order_detail).find(base_field_id+'product_id')) + node_to_string(jQuery(new_order_detail).find(base_field_id+'name'));
  sku = sku + node_to_string(jQuery(new_order_detail).find(base_field_id+'sku'));
  price = price + node_to_string(jQuery(new_order_detail).find(base_field_id+'price'));

  current_table.fnAddData([img,name,sku,price,'1',price_with_currency,remove_link]);
  //update_order_total();
  false_id--;
}

// hide order detail container and set order detail delete value to 1
function remove_order_detail(destroy_link){
  var current_table = jQuery('#table-order-details').dataTableInstance();
  var base_field_id = '#order_order_details_attributes_'+get_rails_element_id(destroy_link)+'_';
  var detail_id = jQuery(base_field_id+'id').val();

  // remove row
  current_table.fnDeleteRow(
      current_table.fnGetPosition(jQuery(destroy_link).parents('tr:first')[0])
  );

  // set order detail deleted
  jQuery(base_field_id+'_destroy').val(1);

  // remove special offer and voucher discount detail
  jQuery('.special_order_detail_'+ detail_id).remove();
  jQuery('.voucher_order_detail_'+ detail_id).remove();

  update_order_total();
}

function update_order_total(){
  var form = jQuery('form.edit_order');
  var url = jQuery(form).attr('action') + '/total';

  jQuery.ajax({
    url: url,
    data: jQuery(form).serialize(),
    success:function(request){
      jQuery('span.order-price').text(request.total);
      jQuery('span.order-total').text(request.total);
      jQuery('span.order-subtotal').text(request.subtotal);
      jQuery('#transporter_rebuild').val(0);
      if (request.rebuild_transporter == 1){
        // remove old transporters
        jQuery('#order_shipping').children().remove();

        // remove custom select
        jQuery('.delivery-method').removeClass('enhanced');
        jQuery('.delivery-method').children('.dropdown').remove();

        // add new available transporters
        for (var i=0; i<request.available_transporters.length; i++){
	      var transporter_rule = request.available_transporters[i].transporter_rule;
	      jQuery('#order_shipping').append('<option value="'+transporter_rule.variables+'">'+transporter_rule.name+'</options>');
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
