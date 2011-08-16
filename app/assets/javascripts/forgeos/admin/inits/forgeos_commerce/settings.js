jQuery(document).ready(function(){
  jQuery('.toggle-infos').each(function(index, html_element){
    var element = jQuery(html_element);
    if (!element.is(':checked')) element.siblings('.infos').hide();
    element.change(function(){
      element.siblings('.infos').toggle();
    });
  });

  jQuery('#accordion_payments').accordion({
    collapsible: true,
    active: false,
    autoHeight: false
  });
});
