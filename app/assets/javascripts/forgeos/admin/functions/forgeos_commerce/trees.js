function init_transporter_tree(selector, type, source) {
  jQuery(selector).jstree({
    data:{
      type: 'json',
      opts: {
        url: source
      }
    },
    ui: {
      theme_path: '/stylesheets/jstree/themes/',
      theme_name : 'categories',
      selected_parent_close: false
    },
    callback: {
      onload: function(TREE_OBJ){
        tree_id = jQuery(TREE_OBJ.container).attr('id');
        jQuery(TREE_OBJ.container).removeClass('tree-default');
        jQuery(TREE_OBJ.container).find('a').each(function(index,selector){
          var category_id = get_rails_element_id(jQuery(selector).parent('li'));
          jQuery(selector).droppable({
            hoverClass: 'ui-state-hover',
            drop:function(ev, ui){
              jQuery.ajax({
              data: {element_id:get_rails_element_id(jQuery(ui.draggable)), authenticity_token: encodeURIComponent(window._forgeos_js_vars.token)},
              success:function(request){jQuery.tree.focused().refresh();},
              type:'post',
              url:'/admin/geo_zones/' + category_id + '/add_element'
              });
            }
          });
        });
      }
    }
  });
}
