jQuery(document).ready(function(){
  init_category_tree('#product-tree','ProductCategory','/admin/product_categories.json');
  init_category_tree("#product-type-tree",'ProductTypeCategory','/admin/product_type_categories.json');
  init_category_tree("#attribute-tree",'AttributeCategory','/admin/attribute_categories.json');
  init_category_tree("#special-offer-tree",'SpecialOfferCategory','/admin/special_offer_categories.json');
  init_category_tree("#brand-tree",'BrandCategory','/admin/brand_categories.json');

  init_association_category_tree('#association-brand-tree', 'brand', 'brand_category', 'association_product');

  //GEOZONES ARE NOT CATEGORIES
  init_transporter_tree("#transporter-tree",'TransporterCategory','/admin/transporter_categories.json');

  //init the zone modify tree
  jQuery("#zone-tree").jstree({
    "themes": {
      "theme": 'zone-tree'
    },
    "ui": {
      "selected_parent_close": false
    },
    "plugins": ['ui', 'theme', "html_data"]
  });

  //init the tree for products/blocks associations
  jQuery("#association-product-tree").bind('select_node.jstree', function(e, data){
    var NODE = data.rslt.obj;
    var object_name = jQuery(NODE).attr('id').split('_')[0];
    var category_id = get_rails_element_id(NODE);
    jQuery(NODE).append('<input type="hidden" id="'+object_name+'_category_'+category_id+'" name="'+object_name+'[category_ids][]" value="'+category_id+'" />');
  }).bind('deselect_node.jstree', function(e, data){
    jQuery(data.rslt.obj).children('input').remove();
  }).jstree({
    "themes": {
      "theme": 'association_product'
    },
    "ui": {
      "selected_parent_close": false
    },
    "plugins": ['themes','html_data', 'ui', 'crrm']
  });

  //init the tree for product-types-selected
  jQuery("#product-types-selected-tree").jstree({
    "themes": {
      "theme": 'product-types',
      "dots": false,
      "icons": false
    },
    "types": {
      "default": {
        "max_depth": 0
      }
    },
    "plugins": ['html_data', 'themes', 'crrm', 'types', 'dnd']
  }).bind('move_node.jstree', function(e, data) {
    var option_id = get_rails_element_id(data.rslt.o);
    jQuery(data.rslt.o).prepend('<input type="hidden" name="product_type[product_attribute_ids][]" value="' + option_id + '" />');
  });

  //init the tree for product-types
  jQuery("#product-types-all-tree").bind('move_node.jstree', function(e, data) {
    jQuery(data.rslt.o).find('input').remove();
  }).jstree({
    "themes": {
      "theme": 'product-types',
      "dots": false,
      "icons": false
    },
    "plugins": ['themes', 'html_data', 'crrm', 'dnd']
  });
});
