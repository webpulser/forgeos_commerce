# Methods for display <i>Cart</i> (in totality, by product, ...).
module CartHelper
  # Display a cart's product
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>carts_product</tt> a <i>CartsProduct</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_cart_by_carts_product(cart, carts_product, static=false, mini=false)
    content = "<div class='cart_product_line' id='forgeos_commerce_cart_product_line_#{carts_product.product_id}'>"
      content += "<div class='cart_name'>"
        content += carts_product.free == 1 ? "Free : #{carts_product.product.name}" : link_to_product(carts_product.product)
      content += "</div>"
      unless mini
        content += "<div class='cart_price'>"
          content +=  carts_product.new_price ? carts_product.new_price.to_s : carts_product.product.price.to_s
        content += "</div>"
        content += "<div class='cart_tax'>"
          content += carts_product.tax.to_s
        content += "</div>"
        content += "<div class='cart_price'>"
          content += carts_product.free == 1 ? "Free" : carts_product.total(carts_product.product).to_s + " " + current_currency.html
        content += "</div>"
      end
      content += "<div class='cart_remove'>"
        unless static
          content += link_to_cart_remove_product(carts_product, mini) unless carts_product.free == 1
        end
      content += "</div>"
    content += "</div>"
  end

  # Display all products lines
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_cart_all_products_lines(cart, static=false, mini=false)
    return I18n.t('your_cart_is_empty').capitalize if cart.nil? || cart.is_empty?
    content = ""
    cart.carts_products.each do |carts_product|
      content += display_cart_by_carts_product(cart, carts_product, static, mini)
    end
    content += "<div class='cart_total'><b>#{I18n.t('total').capitalize} : </b>"
      content += cart.total(true).to_s + " " + current_currency.html
      content += " with special discount : "+ cart.total(true,nil,true).to_s + " " + current_currency.html + " !!" if cart.discount
    content += "</div>"
  end


  # Display a cart
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_cart(cart, static=false, mini=false)
    content = '<div class="cart'+(mini ? ' mini' : '')+'" id="forgeos_commerce_cart">'
      content += "<div class='cart_name'>#{I18n.t('name').capitalize}</div>"
    unless mini
      content += "<div class='cart_name'>#{I18n.t('unit_price').capitalize}</div>"
      content += "<div class='cart_name'>#{I18n.t('tax', :count=>1).capitalize}</div>"
      content += "<div class='cart_name'>#{I18n.t('total').capitalize}</div>"
    end
      content += "<div id='forgeos_commerce_cart_products'>"
        content += display_cart_all_products_lines(cart, static, mini)
      content += "</div>"
    content += "</div>"
    if mini && !cart.is_empty?
      content += '<div class="link_empty">'
      content += link_to_cart_empty(mini)
      content += '</div>'
      content += '<div class="link_order">'
      content += link_to I18n.t('make_order').capitalize, :controller => 'order', :action => 'new'
      content += '</div>'
    end
    content += "<div class='clear'></div>"
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:name</tt> - name, <i>image_tag('forgeos_commerce/remove_product.gif')</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'cart', :action => 'empty'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_cart_remove_product(carts_product, mini=false, name=image_tag('forgeos_commerce/remove_product.gif'), options={:confirm => I18n.t(:confirm_remove_product)})
    if mini
      link_to_remote(name,{ :url=>{:controller => 'cart', :action => 'remove_product', :id => carts_product}, :update => 'cart' }.merge(options))
    else
      link_to(name, {:controller => 'cart', :action => 'remove_product', :id => carts_product}, options)
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i>
  #
  # ==== Parameters
  # * <tt>:name</tt> - name
  # * <tt>:url</tt> - url, <i>{:controller => 'cart', :action => 'empty'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_cart_empty(mini=false,name=I18n.t('empty_cart').capitalize, url={:controller => 'cart', :action => 'empty'}, options={:confirm => I18n.t(:confirm_empty_cart)})
    if mini
      link_to_remote name, { :update => 'cart', :url => url }.merge(options)
    else
      link_to name, url, options
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i>
  #
  # ==== Parameters
  # * <tt>:name</tt> - name, <i>"Cart"</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'cart'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_cart(name=I18n.t('cart', :count => 1), url={:controller => 'cart'}, options=nil)
    #unless cart.nil?
    #  name = "#{name} (#{cart.size} #{I18n.t('product', :count => cart.size)})"
    #end
    link_to name.capitalize, {:controller => 'cart'}, options
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:name</tt> - name, <i>
  # * <tt>:url</tt> - url, <i>{:controller => 'cart', :action => 'add_product'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_add_cart(product, name='add_to_cart', url={:controller => 'cart', :action => 'add_product'}, options=nil)
    link_to I18n.t(name).capitalize, url.merge({:id => product.id}), options
  end
end
