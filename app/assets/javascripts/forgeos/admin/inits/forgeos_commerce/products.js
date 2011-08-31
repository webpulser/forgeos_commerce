jQuery(document).ready(function(){
  //init sortable
  jQuery('.sortable').each(function(){
    jQuery(this).sortable({
      "handle": '.handler',
      "placeholder": 'ui-state-highlight',
      "stop": function(event,ui){
        jQuery('#product-images .sortable li').removeClass('first-image');
        check_product_first_image();
      }
    });
  });

  //init the tool-tip (for product-modify page)
  tool_tip();

  //clone mySlides search input
  jQuery('#product-filter').prepend(jQuery('#mySlides_filter').children('input').clone(true));

  //The first image in product images list got the class first-image & become bigger
  check_product_first_image();

  //when click on add-product-link open the div below
  jQuery('#add-product-link').bind('click', function(){
    jQuery('#existing-products').toggleClass('open');
    jQuery('#existing-products').toggle('blind');
  });

  jQuery('#product_product_type_id, #pack_product_type_id').live('change',function(e){
      jQuery.ajax({
        "before": function(){ tmce_unload_children('#product-types-panel');},
        "data": {
          "product_type_id": jQuery(e.target).val(),
          "authenticity_token": window._forgeos_js_vars.token,
          "id": get_id_from_rails_url()
        },
        "success": function(request){
          jQuery('#product-types-panel').html(request);
          tmce_load_children('#product-types-panel');
        },
        "type": 'post',
        "url": '/admin/products/update_attributes_list'
      });
  });

  jQuery('.add_a_size').live('click', function(){
    var itemInTable = jQuery('#product_sizes tbody tr').length;

    var new_tr = '';
    new_tr += '<tr>'
      new_tr += '<td>'
        new_tr += '<input type="text" name="product[sizes_attributes]['+itemInTable+'][name]" />'
      new_tr += '</td>'
      new_tr += '<td>'
        new_tr += '<input type="text" name="product[sizes_attributes]['+itemInTable+'][quantity]" />'
      new_tr += '</td>'
      new_tr += '<td>'
        new_tr += '<input type="hidden" name="product[sizes_attributes]['+itemInTable+'][id]" />'
        new_tr += '<input type="hidden" name="product[sizes_attributes]['+itemInTable+'][_destroy]" />'
        new_tr += '<input type="hidden" name="product[sizes_attributes]['+itemInTable+'][position]" />'
        new_tr += '<a href="#" class="remove_this_size">supprimer</a>'
      new_tr += '</td>'
    new_tr += '</tr>'

    jQuery('#product_sizes').append(new_tr);
  });

  jQuery('#add-price-variation').live('click', function(e){
    e.preventDefault();
    var index = jQuery('#price-variations .line').size();

    var new_price = "<div class='line'>\
      <input class='center' type='text' size='2' name='product[price_variations_attributes]["+index+"][quantity]' />\
      <label name='product[price_variations_attributes]["+index+"][quantity]' >"+jQuery('#price-variations').attr('data-quantity')+"</label>\
      <input class='center' type='text' size='2' name='product[price_variations_attributes]["+index+"][discount]' />\
      <label name='product[price_variations_attributes]["+index+"][discount]'>"+jQuery('#price-variations').attr('data-discount')+"</label>\
      <a href='#' class='small-icons destroy-link destroy'></a>\
    </div>";

    jQuery('#price-variations').append(new_price);
    return false;
  });

  jQuery('.remove_this_size').live('click', function(e){
    e.preventDefault();
    var block = jQuery(this).parents('tr');
    if (parseInt(get_rails_element_id(block.find('input:first'))) < 0) {
      block.remove();
    } else {
      block.hide();
      block.find('.delete').val(1);
    }
    return false;
  });

  jQuery('#product_sizes tr').sortable({
    handle:'.handler',
    placeholder: 'ui-state-highlight'
  });

  jQuery('#product_sizes').dataTable();

});
