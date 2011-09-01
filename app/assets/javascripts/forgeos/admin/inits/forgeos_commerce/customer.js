jQuery(document).ready(function(){
  jQuery("input[name='same_as_delivery']:checked").live('click', function() {
    if(jQuery(this).val() == 'true') {

      var val_designation = jQuery('#user_address_deliveries_attributes_0_designation').val();
      var val_name = jQuery('#user_address_deliveries_attributes_0_lastname').val();
      var val_firstname = jQuery('#user_address_deliveries_attributes_0_firstname').val();
      var val_address = jQuery('#user_address_deliveries_attributes_0_address').val();
      var val_address_2 = jQuery('#user_address_deliveries_attributes_0_address_2').val();
      var val_zip_code = jQuery('#user_address_deliveries_attributes_0_zip_code').val();
      var val_city = jQuery('#user_address_deliveries_attributes_0_city').val();
      var val_civility = jQuery('#user_address_deliveries_attributes_0_civility').val();
      var val_country_id = jQuery('#user_address_deliveries_attributes_0_country_id').val();

      jQuery('.invoice-address').hide('normal');
      jQuery('#user_address_invoices_attributes_0_designation').val(val_designation);
      jQuery('#user_address_invoices_attributes_0_lastname').val(val_name);
      jQuery('#user_address_invoices_attributes_0_firstname').val(val_firstname);
      jQuery('#user_address_invoices_attributes_0_address').val(val_address);
      jQuery('#user_address_invoices_attributes_0_address_2').val(val_address_2);
      jQuery('#user_address_invoices_attributes_0_zip_code').val(val_zip_code);
      jQuery('#user_address_invoices_attributes_0_city').val(val_city);

      // Custom Selects
      jQuery('#user_address_invoices_attributes_0_civility').val(val_civility);
      var civility_customer_select = jQuery('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html();
      jQuery('#user_address_invoices_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html(civility_customer_select);

      jQuery('#user_address_invoices_attributes_0_country_id').val(val_country_id);
      var country_id_custom_select = jQuery('#user_address_deliveries_attributes_0_country_id').siblings('.dropdown').find('.dropdown_toggle').html();
      jQuery('#user_address_invoices_attributes_0_country_id').siblings('.dropdown').find('.dropdown_toggle').html(country_id_custom_select);

    } else {
      jQuery('.invoice-address').show('normal');
    }
  });
  jQuery('#same_people_infos').live('click', function() {
    if(jQuery(this).is(':checked')) {
      jQuery('.people_infos').hide('normal');
      var val_name = jQuery('#user_lastname').val();
      var val_firstname = jQuery('#user_firstname').val();
      var val_civility = jQuery('#user_civility').val();
      var custom_select_civility = jQuery('#user_civility').siblings('.dropdown').find('.dropdown_toggle').html();

      jQuery('#user_address_deliveries_attributes_0_lastname').val(val_name);
      jQuery('#user_address_deliveries_attributes_0_firstname').val(val_firstname);
      jQuery('#user_address_deliveries_attributes_0_civility').val(val_civility);
      jQuery('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html(custom_select_civility);
    } else {
      jQuery('#user_address_deliveries_attributes_0_lastname').val('');
      jQuery('#user_address_deliveries_attributes_0_firstname').val('');
      jQuery('#user_address_deliveries_attributes_0_civility').val('');
      var civility_default_value =  jQuery('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('options ul li:first .value').text();
      jQuery('#user_address_deliveries_attributes_0_civility').siblings('.dropdown').find('.dropdown_toggle').html('<span>'+civility_default_value+'</span>');
      jQuery('.people_infos').show('normal');
    }
  });
  jQuery('#user_password').change(function(){
    jQuery('#user_password_confirmation').val(jQuery(this).val());
  });
  jQuery('#user_address_deliveries_attributes_0_country_id').change(function(){
    jQuery('#user_country_id').val(jQuery(this).val());
  });
});
