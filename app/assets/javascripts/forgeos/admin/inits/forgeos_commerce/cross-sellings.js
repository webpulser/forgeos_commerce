jQuery(document).ready(function(){
  jQuery('#cross-productSelectDialog').dialog({
    autoOpen:false,
    modal:true,
    minHeight: 300,
    width: 1080,
    resizable:'se',
    buttons: {
     Ok: function(){
       add_cross_to_product();
       jQuery('#cross-productSelectDialog').dialog('close');
     }
    },
    open: function(e,ui){
      eval(jQuery('#table-products-cross').data('dataTables_init_function')+'()');
    }
  });

  jQuery('#cross-product.look').click(function(e){
    e.preventDefault();
    jQuery('#cross-productSelectDialog').dialog('open');
    return false;
  });

  jQuery('.delete_product_tr').live('click',function(e){
    e.preventDefault();
    jQuery(this).parents('tr').remove();
  });

  jQuery('#cross_tree').jstree({
    ui: {
      theme_path: '/stylesheets/jstree/themes/',
      theme_name : 'categories',
      selected_parent_close: false
    },
    callback: {
      onselect: function(NODE,TREE_OBJ) {
        var cat_id = get_rails_element_id(NODE);
        var current_table = jQuery('#table').dataTableInstance();
        var url = current_table.fnSettings().sAjaxSource;
        var url_base = url.split('?')[0];
        var params;
        var link = jQuery(NODE).find('a:first');

        // update category id

        params = get_json_params_from_url(url);

        if (jQuery(link).hasClass('brand')){
          params.type = 'brand';
          ptype_id = jQuery(NODE).parents('ul').prev().attr('id');
          params.ptype_id = ptype_id;
        }else{
          params.type = 'p_type';
        }

        params.category_id = jQuery(link).attr('id');
        params = stringify_params_from_json(params);

        // construct url and redraw table
        update_current_dataTable_source('#table-products','/admin/products.json?' + params);

        object_name = jQuery(NODE).attr('id').split('_')[0];
        category_id = get_rails_element_id(NODE);
        return true;
      }
    }
  });

});
