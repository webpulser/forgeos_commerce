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
      //$('span.order-taxes').text(request.taxes);
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