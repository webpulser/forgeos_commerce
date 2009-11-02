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
            var path = current_table.fnGetData(indexes[i]).slice(-3,-2);
            var id = current_table.fnGetData(indexes[i]).slice(-2,-1);
            var name = current_table.fnGetData(indexes[i]).slice(-1);
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
            var size = current_table.fnGetData(indexes[i]).slice(-6,-5);
            var type = current_table.fnGetData(indexes[i]).slice(-8,-7);
            var id = current_table.fnGetData(indexes[i]).slice(-2,-1);
            var name = current_table.fnGetData(indexes[i]).slice(-1);

            add_attachment_to_product(id,name,size,type);
          }
        });
        $('#fileSelectDialog').dialog('close');
      }
    },
    open: function(){ $('#table-files').dataTableInstance().fnDraw(); }
  });

});
