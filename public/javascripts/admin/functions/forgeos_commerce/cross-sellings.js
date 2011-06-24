function add_cross_to_product() {
  dataTableSelectRows('#table-products-cross', function(current_table,indexes) {
    for(var i=0; i<indexes.length; i++){
      var row = current_table.fnGetData(indexes[i]);
      var id = row.slice(-4,-3);
      var nb_tr = jQuery('.looks_products').find('tr').length;
      var klass = ((nb_tr != 0 && jQuery('.looks_products').find('tr:last').attr('class').match('even')) ? 'odd' : 'even');

      jQuery.get('/admin/get_cross_selling_id', {
        "product_id": parseInt(jQuery('#product_id').html()),
        "cross_selling_id": id,
        "class": klass
      }, function(data){
        jQuery('.looks_products').append(data);
      });
    }
  });
}
