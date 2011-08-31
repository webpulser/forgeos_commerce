function init_transporter_tree(selector, type, source) {
  jQuery(selector).bind('loaded.jstree', function(e, data){
    jQuery(e.target).removeClass('tree-default').find('a').each(function(index,selector){
      var category_id = get_rails_element_id(jQuery(selector).parent('li'));
      jQuery(selector).droppable({
        hoverClass: 'ui-state-hover',
        drop:function(ev, ui){
          jQuery.ajax({
          data: {
            "element_id": get_rails_element_id(jQuery(ui.draggable)),
            "authenticity_token": encodeURIComponent(window._forgeos_js_vars.token)
          },
          success:function(request){jQuery.tree.focused().refresh();},
          type:'post',
          url:'/admin/geo_zones/' + category_id + '/add_element'
          });
        }
      });
    });
  }).jstree({
    "json_data":{
      "ajax": {
        "url": source
      },
      "progressive_render": true
    },
    "themes": {
      "theme": 'categories'
    },
    "ui": {
      "selected_parent_close": false
    },
    "plugins": ['themes', 'json_data', 'ui']
  });
}
