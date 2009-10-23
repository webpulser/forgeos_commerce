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
});