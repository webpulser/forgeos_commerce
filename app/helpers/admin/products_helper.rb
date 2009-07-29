module Admin::ProductsHelper
  def product_categories_tree(category_ids = [])
    content = hidden_field_tag 'product[category_ids][]'
    content += javascript_include_tag %w(jstree/tree_component.min.js jstree/css.js)
    content += stylesheet_link_tag 'jstree/tree_component.css'
    content += javascript_tag do
      "$(function() {
        tree1 = $.tree_create(); tree1.init($('#categories'), {
          ui: { theme_path : '/stylesheets/jstree/themes/', theme_name : 'rails-commerce', context : [] },
          rules : { multiple : 'on' },
          callback : {
            onselect : function(NODE,TREE_OBJ) {
              if (TREE_OBJ.get_type(NODE) == 'folder') {
                $(NODE).children('ul').children().each( function(){TREE_OBJ.select_branch(this,true);})
              } else {
                cat_id = $(NODE).attr('id').replace('category_','');
                if ($('#cat_'+cat_id).size() == 0) { 
                  $('#categories').after('<input id=\"cat_'+cat_id+'\" name=\"product[category_ids][]\" type=\"hidden\" value=\"'+cat_id+'\" /> ');
                } 
              }
            },
            ondeselect : function(NODE,TREE_OBJ) {
              if (TREE_OBJ.get_type(NODE) == 'folder') {
                $(NODE).children('ul').children().each( function(){TREE_OBJ.deselect_branch(this,true);})
              }
              cat_id = $(NODE).attr('id').replace('category_','');
              if ($('#cat_'+cat_id).size() != 0) {
                $('#cat_'+cat_id).remove();
              }
            }
          },
          selected : ['#{category_ids.collect{|cat| "category_#{cat}"}.join('\',\'')}']
        });
      });"
    end
  end
end
