jQuery(document).ready(function(){
  jQuery('#date_option_preview').datepicker({showOn: 'both',buttonText: ''});

  jQuery('#limited-time-offer-end').bind('click', function() {
    jQuery(this).val('');
  });

  jQuery('#limited-time-offer-end').bind('blur', function() {
    jQuery(this).val('dd/mm/yyyy');
  });

  jQuery('input.date-picker').datepicker({
    showOn: 'both',
    buttonText: '',
    changeMonth: true,
    changeYear: true
  });

  //init the special-Offer dataSlide
  jQuery('#specialOffers_products_table').dataSlide({
    "sPaginationType": "full_numbers"
  });
});