/*
 *Show/Hide the stock's tool-tip
 **/
function tool_tip(){
  jQuery(".tool-tip-me").mouseover(function(){
    jQuery(this).children('.tool-tip-content').show();
  });
   jQuery(".tool-tip-me").mouseout(function(){
    jQuery(this).children('.tool-tip-content').hide();
  });
}

function check_product_first_image(){
  jQuery('#product-images .sortable li:eq(0)').addClass('first-image');
}

function add_products_to_pack(){
  dataTableSelectRows('#table-products', function(current_table,indexes) {
    for(var i=0; i<indexes.length; i++){
      var row = current_table.fnGetData(indexes[i]);
      var name = row.slice(-3,-2);
      var id = row.slice(-4,-3);
      var price = row.slice(-1);
      var sku = row.slice(-2,-1);

      jQuery('#pack-products').append('<div class="block-container"><input type="hidden" name="pack[product_ids][]" value="'+id+'" /><span class="block-type"><span class="handler"><span class="inner">&nbsp;</span></span>'+sku+'</span><span class="block-name">'+name+'<span class="file-size"> - '+price+'</span></span><a href="#" class="big-icons gray-destroy"></a></div>');
    }
  });
}

function change_redirection_product(){
  dataTableSelectRows('#table-products', function(current_table,indexes) {
    for(var i=0; i<indexes.length; i++){
      var row = current_table.fnGetData(indexes[i]);
      var id = row.slice(-4,-3);
      var sku = row.slice(-2,-1)[0];
      var img = jQuery(row.slice(0,1)[0]).find('img')[0];
      var name = row.slice(-3,-2);
      var price = row.slice(-1);


      jQuery('#redirection_product_id').val(id);
      jQuery('#redirection_product').html('<div class="block-container"><span class="block-type">'+sku+'</span><span class="block-name">'+name+'<span class="file-size"> - '+price+'</span></span></div>');
    }
  });
}
