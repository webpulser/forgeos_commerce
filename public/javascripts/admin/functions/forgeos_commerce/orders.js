function add_product_to_order_detail(id, name, sku, price, price_with_currency, img){
  // add order detail to datatable
  var current_table = oTables[current_table_index];
  var remove_link = '<a id="order_detail_'+false_id+'" class="small-icons destroy-link" onclick="remove_order_detail($(this));; return false;" href="#"/>';

  current_table.fnAddData([img,name,sku,price,'1',price_with_currency,remove_link]);

  // add hidden field for new order detail and update total
  var new_order_detail = $('<div id="order_detail_' + false_id + '">').html($('#empty_order_detail').html().replace(/EMPTY_ID/g, false_id));
  var base_field_id = '#order_order_details_attributes_'+false_id+'_';

  $(new_order_detail).find(base_field_id+'product_id').val(id);
  $(new_order_detail).find(base_field_id+'name').val(name);
  $(new_order_detail).find(base_field_id+'price').val(price);
  $(new_order_detail).find(base_field_id+'sku').val(sku);
  $('#order_details').append(new_order_detail);

  //update_order_total();
  false_id--;
}

// hide order detail container and set order detail delete value to 1
function remove_order_detail(destroy_link){
  var detail_id = get_rails_element_id(destroy_link);
  var current_table = oTables[1];

  // remove row
  current_table.fnDeleteRow(
      current_table.fnGetPosition($(destroy_link).parents('tr')[0])
  );

  // set order detail deleted
  $('#_delete_order_detail_' + detail_id).val(1);
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

/* Discard inline crud */
function discard() {
  $('#new_right').remove();
  $('.create-right').parent().show();
  $('#table').find('.edit-right').show();
  $('#table').find('.duplicate-right').show();
  $('#table').unwrap();
}

/* Disable all edit-right & duplicate-right & the create right button*/
function disable_links() {
  $('.create-right').parent().hide();
  $('#table').find('.edit-right').hide();
  $('#table').find('.duplicate-right').hide();
}

function form_ajax_right(url, method){
  onsubmit_ajax = "$.ajax({\n\
      success: function(result){\n\
        oTables[current_table_index].fnDraw(); \n\
        $('#table').unwrap(); \n\
        $('.create-right').parent().show();\n\
      }, \n\
      error: function(){\n\
        display_notifications();\n\
      }, \n\
      data: $.param($(this).serializeArray()) + '&authenticity_token=' + encodeURIComponent('" + AUTH_TOKEN + "'), \n\
      dataType: 'script', \n\
      type: '"+method+"', \n\
      url: '"+url+"'\n\
    }); \n\
    return false;"

  return onsubmit_ajax;
}