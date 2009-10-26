jQuery(document).ready(function(){
  $("input[name='same_as_delivery']:checked").live('click', function() {
    if($(this).val() == 'true') {

      var val_designation = $('#user_address_deliveries_attributes_0_designation').val();
      var val_name = $('#user_address_deliveries_attributes_0_name').val();
      var val_firstname = $('#user_address_deliveries_attributes_0_firstname').val();
      var val_address = $('#user_address_deliveries_attributes_0_address').val();
      var val_address_2 = $('#user_address_deliveries_attributes_0_address_2').val();
      var val_zip_code = $('#user_address_deliveries_attributes_0_zip_code').val();
      var val_city = $('#user_address_deliveries_attributes_0_city').val();
      var val_civility = $('#user_address_deliveries_attributes_0_civility').val();
      var val_country_id = $('#user_address_deliveries_attributes_0_country_id').val();

      $('.invoice-address').hide('normal');
      $('#user_address_invoices_attributes_0_designation').val(val_designation);
      $('#user_address_invoices_attributes_0_name').val(val_name);
      $('#user_address_invoices_attributes_0_firstname').val(val_firstname);
      $('#user_address_invoices_attributes_0_address').val(val_address);
      $('#user_address_invoices_attributes_0_address_2').val(val_address_2);
      $('#user_address_invoices_attributes_0_zip_code').val(val_zip_code);
      $('#user_address_invoices_attributes_0_city').val(val_city);

      // Custom Selects
      $('#user_address_invoices_attributes_0_civility').val(val_civility);
      var civility_customer_select = $('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html();
      $('#user_address_invoices_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html(civility_customer_select);

      $('#user_address_invoices_attributes_0_country_id').val(val_country_id);
      var country_id_custom_select = $('#user_address_deliveries_attributes_0_country_id').siblings('.dropdown').find('.dropdown_toggle').html();
      $('#user_address_invoices_attributes_0_country_id').siblings('.dropdown').find('.dropdown_toggle').html(country_id_custom_select);

    } else {
      $('.invoice-address').show('normal');
    }
  });
  $('#same_people_infos').live('click', function() {
    if($(this).is(':checked')) {
      $('.people_infos').hide('normal');
      var val_name = $('#user_lastname').val();
      var val_firstname = $('#user_firstname').val();
      var val_civility = $('#user_civility').val();
      var custom_select_civility = $('#user_civility').siblings('.dropdown').find('.dropdown_toggle').html();
      
      $('#user_address_deliveries_attributes_0_name').val(val_name);
      $('#user_address_deliveries_attributes_0_firstname').val(val_firstname);
      $('#user_address_deliveries_attributes_0_civility').val(val_civility); 
      $('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html(custom_select_civility);
    } else {
      $('#user_address_deliveries_attributes_0_name').val('');
      $('#user_address_deliveries_attributes_0_firstname').val('');
      $('#user_address_deliveries_attributes_0_civility').val('');
      var civility_default_value =  $('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('options ul li:first .value').text();
      $('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html('<span>'+civility_default_value+'</span>');
      $('.people_infos').show('normal');
    }
  });
  $('#user_password').change(function(){
    $('#user_password_confirmation').val($(this).val());
  });
  $('#user_address_deliveries_attributes_0_country_id').change(function(){
    $('#user_country_id').val($(this).val());
  });
});
