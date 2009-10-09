jQuery(document).ready(function(){
  $('#date_option_preview').datepicker({showOn: 'both',buttonText: ''});
  $('input.date-picker').datepicker({showOn: 'both',buttonText: ''});

  //init the special-Offer dataSlide
  $('#specialOffers_products_table').dataSlide({
    "sPaginationType": "full_numbers"
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
        url:'/admin/products/update_tattributes_list'
      });
  });

});