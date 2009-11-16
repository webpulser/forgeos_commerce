# Methods for display <i>Category</i>
module CategoryHelper
  # Display all tree struct <i>Category</i>
  def display_categories(categories=Category::roots)
    content = '<div class="categories">'
      categories.each do |category|
        content += display_category(category)
      end
    content += "</div>"    
  end

  # Display one tree struct <i>Category</i>
  def display_category(category)
    current_category = Category.find_by_id(params[:id])

    content = '<div class="category">'
      (0..category.level).each do |i|
        content += "&nbsp;"
      end
      unless category.children.empty?
        content += link_to_function category.name, visual_effect('appear', "category_#{category.id}")
        content += "<div id=\"category_#{category.id}\" " + ((current_category && current_category.parent.eql?(category)) ? '' : 'style="display: none;"') + '>'
          category.children.each do |subcategory|
            content += display_category(subcategory)
          end
        content += "</div>"
      else
        content += link_to_unless current_category && current_category.eql?(category), category.name, :controller => 'catalog', :action => 'category', :id => category
      end
    content += "</div>"
  end

  def link_to_category(category)

  end
end
