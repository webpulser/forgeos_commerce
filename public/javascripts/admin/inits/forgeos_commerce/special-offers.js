jQuery(document).ready(function(){
  $('#date_option_preview').datepicker({showOn: 'both',buttonText: ''});

  $('input.date-picker').datepicker({
    showOn: 'both',
    buttonText: '',
    changeMonth: true,
    changeYear: true
  });

  //init the special-Offer dataSlide
  $('#specialOffers_products_table').dataSlide({
    "sPaginationType": "full_numbers"
  });
});