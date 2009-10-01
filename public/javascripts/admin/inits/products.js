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
});