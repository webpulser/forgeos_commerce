jQuery(document).ready(function(){
  $($("input[@name='same_as_delivery']:checked")).live('click', function() {
    if($(this).val() == 'true') {

      val_designation = $('#user_address_invoices_attributes_0_designation').val();
      val_name = $('#user_address_invoices_attributes_0_name').val();
      val_firstname = $('#user_address_invoices_attributes_0_firstname').val();
      val_address = $('#user_address_invoices_attributes_0_address').val();
      val_address2 = $('#user_address_invoices_attributes_0_address2').val();
      val_zip_code = $('#user_address_invoices_attributes_0_zip_code').val();
      val_city = $('#user_address_invoices_attributes_0_city').val();
      val_civility_id = $('#user_address_invoices_attributes_0_civility_id').val();
      val_country_id = $('#user_address_invoices_attributes_0_country_id').val();

      $('.delivery-address').hide('normal');
      $('#user_address_deliveries_attributes_0_designation').val(val_designation);
      $('#user_address_deliveries_attributes_0_name').val(val_name);
      $('#user_address_deliveries_attributes_0_firstname').val(val_firstname);
      $('#user_address_deliveries_attributes_0_address').val(val_address);
      $('#user_address_deliveries_attributes_0_address2').val(val_address2);
      $('#user_address_deliveries_attributes_0_zip_code').val(val_zip_code);
      $('#user_address_deliveries_attributes_0_city').val(val_city);

      // Custom Selects
      $('#user_address_deliveries_attributes_0_civility_id').val(val_civility_id);
      civility_id_customer_select = $('#user_address_invoices_attributes_0_civility_id').siblings('.dropdown').find('.dropdown_toggle').html();
      $('#user_address_deliveries_attributes_0_civility_id').siblings('.dropdown').find('.dropdown_toggle').html(civility_id_customer_select);

      $('#user_address_deliveries_attributes_0_country_id').val(val_country_id);
      country_id_custom_select = $('#user_address_invoices_attributes_0_country_id').siblings('.dropdown').find('.dropdown_toggle').html();
      $('#user_address_deliveries_attributes_0_country_id').siblings('.dropdown').find('.dropdown_toggle').html(country_id_custom_select);

    } else {
      $('.delivery-address').show('normal');
    }

  });
});