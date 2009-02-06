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

  def display_all_products(products=ProductDetail.find(:all), with_description=false)
    content = "<div class='products'>"
    products.each do |product|
      content += display_product(product, with_description)
    end
    content += "</div>"
  end

  def display_product(product, with_description=false, options={})
    return I18n.t('no_product') unless product
    content = "<div class='product'>"
      if product.pictures.first
        content += "<div class='product_picture'>"
          content += image_tag(product.pictures.first.public_filename(options[:thumbnail_type] || :thumb))
        content += "</div>"
      end
      content += "<div class='product_name'>"
        content += link_to_product product
      content += "</div>"
      content += "<div class='product_price'>"
        content += product.price_to_s(true)
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
  end
  
  def display_product_page(product)
    content = '<div class="large">'
      content += '<div class="product_show">'
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
        content += '<div class="product_picture">'
          content += image_tag(product.pictures.first.public_filename(:normal)) unless product.pictures.empty?
        content += '</div>'
        content += '<div class="product_attributes_groups" id="product_attributes_groups_' + product.id.to_s + '">'
          content += display_product_page_attributes(product)
        content += '</div>'
        content += '<div class="product_price">'
          content += '<div class="product_price_label">'
            content += 'price:&nbsp;'
          content += '</div>'
          content += '<div class="product_price_value" id="display_product_page_price_' + product.id.to_s + '">'
            if product.product_details.size == 1
              content += product.product_details.first.price_to_s(true)
            else
              content += product.price_to_s(true)
            end
          content += '</div>'
        content += '</div>'
        content += '<div class="product_link_cart" id="display_product_link_cart_' + product.id.to_s + '">'
          if product.product_details.size == 1
            content += link_to_add_cart(product.product_details.first)
          else
            content += I18n.t(RailsCommerce::OPTIONS[:text][:add_to_cart])
          end
        content += '</div>'
      content += '</div>'
    content += '</div>'
  end
  
  def display_product_page_attributes(product, options_attributes=nil)
    options_attributes = session["product_#{product.id}"][:attributes] if options_attributes.nil? && session["product_#{product.id}"]

    content = ""
    product.attributes_groups.each do |attributes_group|
      content += "<div class='product_attribute_group_name'>"
        content += attributes_group.name + "&nbsp;:&nbsp;"
      content += "</div>"
      content += '<div class="product_attributes">'
        attributes_group.tattributes.each do |attribute|
          content += '<div class="product_attribute">'
            if product.product_details.find(:first, :conditions => ["#{Attribute.table_name}.id = ?", attribute.id], :include => 'tattributes')
              if options_attributes && options_attributes[attributes_group.id] && options_attributes[attributes_group.id].id == attribute.id
                content += attribute.name
              else
                content += link_to_remote(attribute.name, :url => { :controller => 'product', :action => 'update', :id => product.id, :attribute_id => attribute.id })
              end
            end
          content += "</div>"
        end
      content += '</div>'
      content += "<div class='clear'></div>"
    end
    return content
  end
  
  def link_to_catalog(name=I18n.t("Catalog"), url={:controller => 'catalog'}, options=nil)
    link_to name, :controller => 'catalog'
  end
  
  def link_to_product(product, name=nil, url={:controller => 'product', :action => 'show'}, options=nil)
    name = product.name if name.nil?
    link_to name, url.merge(:id => ((product.is_a?(ProductDetail)) ? product.product_parent : product.id)), options
  end
end
