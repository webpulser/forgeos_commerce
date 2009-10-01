jQuery(document).ready(function(){
  init_tree('#product-tree','ProductCategory', '/admin/products.json','/admin/product_categories.json');
  init_tree("#product-type-tree",'ProductTypeCategory', '/admin/product_types.json','/admin/product_type_categories.json');
  init_tree("#option-tree",'OptionCategory', '/admin/options.json','/admin/option_categories.json');

  //init the zone modify tree
   $("#zone-tree").tree({
    ui: { theme_path: '/stylesheets/jstree/themes/', theme_name : 'zone-tree' },
    rules: { multiple:'on' },
    callback: {
      onload: function(TREE_OBJ){
        tree_id = $(TREE_OBJ.container).attr('id');
        $(TREE_OBJ.container).removeClass('tree-default');
      }
    }
  });

  //init the tree for products/blocks associations
  $("#association-product-tree").tree({
    ui: { theme_path: '/stylesheets/jstree/themes/', theme_name : 'association_product'},
    rules: { multiple:'on' },
    callback: {
      onload: function(TREE_OBJ){
        tree_id = $(TREE_OBJ.container).attr('id');
        $(TREE_OBJ.container).removeClass('tree-default');
      },
      onrgtclk: function(NODE,TREE_OBJ,EV){
        EV.preventDefault(); EV.stopPropagation(); return false
      },
      onselect: function(NODE,TREE_OBJ){
        object_name = $(NODE).attr('id').split('_')[0];
        category_id = get_rails_element_id(NODE);
        $(NODE).append('<input type="hidden" id="'+object_name+'_product_category_'+category_id+'" name="'+object_name+'[product_category_ids][]" value="'+category_id+'" />');
        $(NODE).addClass('clicked');
      },
      ondeselect: function(NODE,TREE_OBJ){
        object_name = $(NODE).attr('id').split('_')[0];
        category_id = get_rails_element_id(NODE);
        $(NODE).children('input').remove();
        $(NODE).removeClass('clicked');
      }
    }
  });

  //init the tree for product-types
  $("#product-types-all-tree").tree({
    ui: { theme_path: '/stylesheets/jstree/themes/', theme_name : 'product-types-all'},
    rules: {
        multitree : true,
        type_attr : 'rel',
        draggable : ['attribute'],
        clickable: ['attribute'],
        dragrules :['attribute after attribute','attribute before attribute'],
        drag_copy : 'on'
   },
   callback: {
      onload: function(TREE_OBJ){
        tree_id = $(TREE_OBJ.container).attr('id');
        $(TREE_OBJ.container).removeClass('tree-default');
      },
      onmove: function(NODE) {
        option_id = get_rails_element_id(NODE);
        $('#product_type_option_ids_'+option_id).remove();
      }
   }
  });
  //init the tree for product-types-selected
  $("#product-types-selected-tree").tree({
    ui: { theme_path: '/stylesheets/jstree/themes/', theme_name : 'product-types-selected'},
    rules: {
        multitree : true,
        type_attr : 'rel',
        draggable : ['attribute'],
        clickable: ['attribute'],
        dragrules :['attribute after attribute','attribute before attribute' ]
    },
    callback: {
      onload: function(TREE_OBJ){
        tree_id = $(TREE_OBJ.container).attr('id');
        $(TREE_OBJ.container).removeClass('tree-default');
      },
      oncopy  : function(NODE) {
        option_id = NODE.id.split('_')[1];

        if (!$('#product_type_option_ids_'+option_id).is(':empty')) {
          NODE.id = 'option_'+option_id;
          $('a', NODE).append('<input type="hidden" id="product_type_option_ids_'+option_id+'" name="product_type[option_ids][]" value="'+option_id+'" />');
        } else {
          $('#option_'+option_id+'_copy').remove();
        }
      }
    }
  });
});