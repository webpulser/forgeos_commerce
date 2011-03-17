function init_transporter_tree(selector, type, source) {
  $(selector).tree({
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
        tree_id = $(TREE_OBJ.container).attr('id');
        display_notifications();
        $(TREE_OBJ.container).removeClass('tree-default');
        $(TREE_OBJ.container).find('a').each(function(index,selector){
          var category_id = get_rails_element_id($(selector).parent('li'));
          $(selector).droppable({
            hoverClass: 'ui-state-hover',
            drop:function(ev, ui){
              $.ajax({
              data: {element_id:get_rails_element_id($(ui.draggable)), authenticity_token: encodeURIComponent(AUTH_TOKEN)},
              success:function(request){$.tree.focused().refresh();},
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
