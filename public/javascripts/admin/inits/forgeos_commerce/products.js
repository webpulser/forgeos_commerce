jQuery(document).ready(function(){
  //init sortable
  $('.sortable').each(function(){
    $(this).sortable({
      handle:'.handler',
      placeholder: 'ui-state-highlight',
      stop:function(event,ui){
        $('#product-images .sortable li').removeClass('first-image');
        check_product_first_image();
      }
    });
  });

  //init the tool-tip (for product-modify page)
  tool_tip();

  //clone mySlides search input
  $('#product-filter').prepend($('#mySlides_filter').children('input').clone(true));

  //The first image in product images list got the class first-image & become bigger
  check_product_first_image();

  //when click on add-product-link open the div below
  $('#add-product-link').bind('click', function(){
    $('#existing-products').toggleClass('open');
    $('#existing-products').toggle('blind');
  });

  $('#product_product_type_id, #pack_product_type_id').live('change',function(e){
      $.ajax({
        before: function(){ tmce_unload_children('#product-types-panel');},
        data: { product_type_id: $(e.target).val(), authenticity_token: AUTH_TOKEN, id: get_id_from_rails_url() },
        success: function(request){
          $('#product-types-panel').html(request);
          InitCustomSelects();
          tmce_load_children('#product-types-panel');
        },
        type:'post',
        url:'/admin/products/update_attributes_list'
      });
  });

  $('#imageSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 380,
    width: 800,
    resizable:'se',
    buttons: {
      Ok: function(){
        dataTableSelectRows('#image-table:visible,#thumbnail-table:visible',function(current_table,indexes){
          for(var i=0; i<indexes.length; i++){
            var row = current_table.fnGetData(indexes[i]);
            var path = row.slice(-3,-2);
            var id = row.slice(-2,-1);
            var name = row.slice(-1);
            add_picture_to_element(path,id,name);
          }
          check_product_first_image();
        });
        $('#imageSelectDialog').dialog('close');
      }
    },
    open: function(){ $('#image-table:visible,#thumbnail-table:visible').dataTableInstance().fnDraw(); }
  });

  $('#fileSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 380,
    width: 800,
    resizable:'se',
    buttons: {
      Ok: function(){
        dataTableSelectRows('#table-files', function(current_table, indexes) {
          for(var i=0; i<indexes.length; i++){
            var row = current_table.fnGetData(indexes[i]);
            var size = row.slice(-6,-5);
            var type = row.slice(-8,-7);
            var id = row.slice(-2,-1);
            var name = row.slice(-1);

            add_attachment_to_product(id,name,size,type);
          }
        });
        $('#fileSelectDialog').dialog('close');
      }
    },
    open: function(){ $('#table-files').dataTableInstance().fnDraw(); }
  });

$('.add_a_size').live('click', function(){
    var itemInTable = $('#product_sizes tbody tr').length;

    var new_tr = '';
    new_tr += '<tr>'
      new_tr += '<td>'
        new_tr += '<input type="text" name="product[sizes_attributes]['+itemInTable+'][size]" />'
      new_tr += '</td>'
      new_tr += '<td>'
        new_tr += '<input type="text" name="product[sizes_attributes]['+itemInTable+'][quantity]" />'
      new_tr += '</td>'
      new_tr += '<td>'
        new_tr += 'visible'
      new_tr += '</td>'
      new_tr += '<td>'
        new_tr += '<input type="hidden" name="product[sizes_attributes]['+itemInTable+'][id]" />'
        new_tr += '<input type="hidden" name="product[sizes_attributes]['+itemInTable+'][_destroy]" />'
        new_tr += '<input type="hidden" name="product[sizes_attributes]['+itemInTable+'][position]" />'
        new_tr += '<a href="#" class="remove_this_size">supprimer</a>'
      new_tr += '</td>'
    new_tr += '</tr>'

    $('#product_sizes').append(new_tr);
  });

  $('.remove_this_size').live('click', function(){
    var block = $(this).parents('tr');
    if (parseInt(get_rails_element_id(block.find('input:first'))) < 0) {
      console.info('- 0')
      block.remove();
    } else {
      console.info('+0')
      block.hide();
      block.find('.delete').val(1);
    }
    return false;
  });

  $('#product_sizes tr').sortable({
    handle:'.handler',
    placeholder: 'ui-state-highlight',
    stop:function(event,ui){
      console.info('hi');
    }
  });

  $('#product_sizes').dataTable();

});
