jQuery(document).ready(function(){  
  $('#cross-productSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 300,
    width: 1080,
    resizable:'se',
    buttons: {
     Ok: function(){
       add_cross_to_product();
       $('#cross-productSelectDialog').dialog('close');
     }
    },
    open: function(){ $('table-products-cross').dataTableInstance().fnDraw(); }
  });

  $('#cross-product.look').click(function(){
    $('#cross-productSelectDialog').dialog('open');
    return false;
  });
  
  $('.delete_product_tr').live('click',function(){
    $(this).parents('tr').remove();
  });  
  
  $('#cross_tree').tree({
    ui: {
      theme_path: '/stylesheets/jstree/themes/',
      theme_name : 'categories',
      selected_parent_close: false
    },
    callback: {
      onselect: function(NODE,TREE_OBJ) {
        var cat_id = get_rails_element_id(NODE);
        var current_table = $('#table').dataTableInstance();
        var url = current_table.fnSettings().sAjaxSource;
        var url_base = url.split('?')[0];
        var params;
        var link = $(NODE).find('a:first');

        // update category id
        
        params = get_json_params_from_url(url);
        
        if ($(link).hasClass('brand')){
          params.type = 'brand';
          ptype_id = $(NODE).parents('ul').prev().attr('id');
          params.ptype_id = ptype_id;
        }else{
          params.type = 'p_type';
        }
        
        params.category_id = $(link).attr('id');
        params = stringify_params_from_json(params);

        // construct url and redraw table
        update_current_dataTable_source('#table-products','/admin/products.json?' + params);

        object_name = $(NODE).attr('id').split('_')[0];
        category_id = get_rails_element_id(NODE);
        return true;
      }
    }
  });
  
  

});
