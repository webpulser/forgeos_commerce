function add_cross_to_product(){
  dataTableSelectRows('#table-products-cross', function(current_table,indexes) {
    for(var i=0; i<indexes.length; i++){
      var row = current_table.fnGetData(indexes[i]);
      var stock = row.slice(-8,-7);
      var image = row.slice(-12,-11);
      var name = row.slice(-3,-2);
      var id = row.slice(-4,-3);
      var price = row.slice(-1);
      var sku = row.slice(-2,-1);
      var nb_tr = $('.looks_products').find('tr').length;
      var class = 'even';
	  
	  if (nb_tr != 0){
      	var class =  $('.looks_products').find('tr:last').attr('class');
		if(class.match('even')){
			class = 'odd'
		}else{
			class = 'even'
		}
	  }
		
      $.get('/admin/get_cross_selling_id', {
        product_id: parseInt($('#product_id').html()),
        cross_selling_id: id,
		class: class,
      }, function(data){
        $('.looks_products').append(data);
      })
    }
  });
}