/*
 *Show/Hide the stock's tool-tip
 **/
function tool_tip(){
  $(".tool-tip-me").mouseover(function(){
    $(this).children('.tool-tip-content').show();
  });
   $(".tool-tip-me").mouseout(function(){
    $(this).children('.tool-tip-content').hide();
  });
}

function check_product_first_image(){
  $('#product-images .sortable li:eq(0)').addClass('first-image');
}

function add_products_to_pack(){
  dataTableSelectRows('#table-products', function(current_table,indexes) {
    for(var i=0; i<indexes.length; i++){
      var row = current_table.fnGetData(indexes[i]);
      var name = row.slice(-3,-2);
      var id = row.slice(-4,-3);
      var price = row.slice(-1);
      var sku = row.slice(-2,-1);

      $('#pack-products').append('<div class="block-container"><input type="hidden" name="pack[product_ids][]" value="'+id+'" /><span class="block-type"><span class="handler"><span class="inner">&nbsp;</span></span>'+sku+'</span><span class="block-name">'+name+'<span class="file-size"> - '+price+'</span></span><a href="#" class="big-icons gray-destroy"></a></div>');
    }
  });
}
