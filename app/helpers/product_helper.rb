module ProductHelper
  
  def display_catalog(products)
    total = (products.is_a?(WillPaginate::Collection)) ? products.total_entries : products.size
    content = pluralize total, "result"

    products.in_groups_of(RailsCommerce::OPTIONS[:product_in_groups_of]).each do |products_|
      products_.each do |product|
        content += display_product(product) if product
      end
      content += '<div class="clear"></div>'
    end

    content += will_paginate(products).to_s if products.is_a?(WillPaginate::Collection)
    return content
  end

  def display_all_products(products=Product.find_all_by_active_and_deleted(true,false), with_description=false)
    content = ''
    products.each do |product|
      content << display_product(product, with_description)
    end
    content_tag :div, content, :class=>'products'
  end

  def display_product(product, with_description=false, options={})
    return I18n.t('no_product') unless product
    content = "<div id=\"product_#{product.id}\" class=\"product\">"
      if product.attachments.find_all_by_type('Picture').first
        content += "<div class='product_picture'>"
          content += image_tag(product.attachments.find_all_by_type('Picture').first.public_filename(options[:thumbnail_type] || :thumb))
        content += "</div>"
      end
      content += "<div class='product_name'>"
        content += link_to_product product
      content += "</div>"
      content += "<div class='product_price'>"
        content += product.price_to_s(true)
        #content += product.price.to_s
      content += "</div>"
      content += "<div class='product_add_cart'>"
        content += link_to_add_cart(product)
      content += "</div>"
      if with_description
        content += "<div class='product_description'>"
          content += product.description
        content += "</div>"
      end
    content += "</div>"
    content += draggable_element("product_#{product.id}", :helper => '"clone"')
  end
  
  def display_product_page(product)
    content = '<div class="large">'
      content += '<div id="product_'+product.id.to_s+'" class="product_show">'
              content += '<div class="product_name">'
                      content += '<h1>'
                        content += "<div id='display_product_page_name_#{product.id}'>"
                          content += product.name
                        content += "</div>"
                      content += '</h1>'
              content += '</div>'
        content += '<br /><br />'
              content += '<div class="product_description">'
               content += product.description
              content += '</div>'
        content += '<div class="product_picture" id="display_product_pictures_'+product.id.to_s+'">'
          product.pictures.each do |picture|
            content += (picture == product.pictures.first ? image_tag(picture.public_filename('')) : image_tag(picture.public_filename(:small)))
          end
          #content += image_tag(product.attachments.find_all_by_type('Picture').first.public_filename(:normal)) unless product.attachments.find_all_by_type('Picture').empty?
        content += '</div>'
        content += '<div class="product_attributes_groups" id="product_attributes_groups_' + product.id.to_s + '">'
          content += display_product_page_attributes(product)
        content += '</div>'
        content += '<div class="product_price">'
          content += '<div class="product_price_label">'
            content += 'price:&nbsp;'
          content += '</div>'
          content += '<div class="product_price_value" id="display_product_page_price_' + product.id.to_s + '">'
          content += product.price_to_s(true)
          content += '</div>'
        content += '</div>'
        content += '<div class="product_link_cart" id="display_product_link_cart_' + product.id.to_s + '">'
          content += link_to_add_cart(product)
        content += '</div>'
      content += '</div>'
    content += '</div>'

    content += draggable_element("product_#{product.id}", :cursor => '"move"', :helper => "function(event) { return $('<div class=\"ui-widget-header\">#{escape_javascript(product.name)}</div>'); }" )
  end
  
  def display_product_page_attributes(product)
    content = ""
    return content unless product && product.product_type
    product.product_type.tattributes.each do |tattribute|
      content += "<div class='product_attribute_group_name'>"
        content += tattribute.name + "&nbsp;:&nbsp;"
      content += "</div>"
      content += '<div class="product_attributes">'
        tattribute.tattribute_values.each do |tattribute_value|
          content += '<div class="product_attribute">'
            content += tattribute_value.name
          content += "</div>"
        end
      content += '</div>'
      content += "<div class='clear'></div>"
    end
    content
  end
  
  def link_to_product(product, name=nil, url={:controller => 'product', :action => 'show'}, options=nil)
    name = product.name if name.nil?
    link_to name, product, options
  end
end
