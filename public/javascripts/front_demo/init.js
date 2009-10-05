$(function(){
  
  $('.opener').live('click',function(){
    $(this).toggleClass('opened');
    $('.cart-box .jcarousel-container-vertical').toggle('blind');
  });

  $('#login_link').live('click',function() {
    $('#login_container').toggle('blind');
    return false;
  });

  $('.cart-products').jcarousel({
    vertical: true,
    visible: 4
  });

  $('.cart-box .jcarousel-container-vertical').attr({style:''});

  $('.to_tab').tabs();

  $('.slider_product, .colors, .sizes, .cross-sells').jcarousel();

   var options = {
    zoomWidth: 300,
    zoomHeight: 300,
    xOffset: 10,
    yOffset: 0,
    lens: true,
    title: false,
    position: "right",
    showPreload: true,
    mouseOutCallback: bind_images_click
  };
  
	$('.jqzoom').jqzoom(options);

  $('#slider_products').find('a').live('click',function(){
    $(this).toggleClass('clicked');
  });
  $('.colors').find('a').live('click',function(){
    $(this).toggleClass('clicked');
    return false;
  });
  $('.sizes').find('a').live('click',function(){
    $(this).toggleClass('clicked');
    return false;
  });

  //Remove this MF cheat
  $('.order_shipping_method_name').find('input:radio').click();

  bind_images_click();
})

function bind_images_click(){
  var options = {
    zoomWidth: 300,
    zoomHeight: 300,
    xOffset: 10,
    yOffset: 0,
    lens: true,
    title: false,
    position: "right",
    showPreload: true,
    mouseOutCallback: bind_images_click
  };

  $('.other_views img').live('click',function(){
    var first_image = $('.jqzoom').find('img');
    var clicked_img = $(this);
    var to_add = '<a href="'+clicked_img.attr('alt')+'" class="jqzoom"><img src="'+clicked_img.attr('src')+'" alt="'+clicked_img.attr('alt')+'"/></a>';
    $(this).remove();
    $('.other_views').append(first_image);
    $('.first_image_container').html(to_add);
    $('.jqzoom').jqzoom(options);
    return false;
  })
}