# Methods for display <i>Wishlist</i> (in totality, by product, ...).
module WishlistHelper
  # Display a wishlist's product
  #
  # == Parameters
  # * <tt>wishlist</tt> a <i>Wishlist</i> object
  # * <tt>wishlists_product</tt> a <i>WishlistsProduct</i> object
  # * <tt>static</tt> add action's buttons for edit this wishlist if true, false by default
  def display_wishlist_by_wishlists_product(wishlist, wishlists_product, static=false, mini=false)
    content = "<div class='wishlist_product_line' id='forgeos_commerce_wishlist_product_line_#{wishlists_product.product_id}'>"
      content += "<div class='wishlist_name'>"
        content += link_to_product(wishlists_product.product)
      content += "</div>"
      content += "<div class='wishlist_quantity'>"
        if static
          content += wishlists_product.quantity.to_s
        else
          content += text_field_tag "wishlist_quantity_#{wishlists_product.product_id}", wishlists_product.quantity.to_s, :size => 2
          content += observe_field("wishlist_quantity_#{wishlists_product.product_id}", :frequency => 1, :loading => "$('#spinner2').show()", :complete => "$('#spinner2').hide()", :url => { :controller => 'wishlist', :action => 'update_quantity', :mini => mini }, :with => "'quantity=' + escape(value) + '&product_id=#{wishlists_product.product_id}'")
        end
      content += "</div>"
      unless mini
        content += "<div class='wishlist_price'>"
          content += wishlists_product.product.price.to_s
        content += "</div>"
        content += "<div class='wishlist_tax'>"
          content += wishlists_product.tax.to_s
        content += "</div>"
        content += "<div class='wishlist_price'>"
          content += wishlists_product.total(wishlists_product.product).to_s + " " + $currency.html
        content += "</div>"
      end
      content += "<div class='wishlist_remove'>"
        unless static
          content += link_to_wishlist_remove_product(wishlists_product.product, mini)
        end
      content += "</div>"
    content += "</div>"
  end

  # Display all products lines
  #
  # == Parameters
  # * <tt>wishlist</tt> a <i>Wishlist</i> object
  # * <tt>static</tt> add action's buttons for edit this wishlist if true, false by default
  def display_wishlist_all_products_lines(wishlist, static=false, mini=false)
    return I18n.t('your_wishlist_is_empty').capitalize if wishlist.nil? || wishlist.is_empty?
    content = ""
    wishlist.products_wishlists.each do |wishlists_product|
      content += display_wishlist_by_wishlists_product(wishlist, wishlists_product, static, mini)
    end
    content += "<div class='wishlist_total'><b>#{I18n.t('total').capitalize} : </b>"
      content += wishlist.total(true).to_s + " " + $currency.html
    content += "</div>"
  end
  

  # Display a wishlist
  #
  # == Parameters
  # * <tt>wishlist</tt> a <i>Wishlist</i> object
  # * <tt>static</tt> add action's buttons for edit this wishlist if true, false by default
  def display_wishlist(wishlist, static=false, mini=false)
    content = '<div class="wishlist'+(mini ? ' mini' : '')+'" id="forgeos_commerce_wishlist">'
      content += "<div class='wishlist_name'>#{I18n.t('name').capitalize}</div>"
      content += "<div class='wishlist_name'>#{I18n.t('quantity', :count=>1).capitalize}</div>"
    unless mini
      content += "<div class='wishlist_name'>#{I18n.t('unit_price').capitalize}</div>"
      content += "<div class='wishlist_name'>#{I18n.t('tax', :count=>1).capitalize}</div>"
      content += "<div class='wishlist_name'>#{I18n.t('total').capitalize}</div>"
    end
      content += "<div id='forgeos_commerce_wishlist_products'>"
        content += display_wishlist_all_products_lines(wishlist, static, mini)
      content += "</div>"
    content += "</div>"
    if mini && !wishlist.is_empty?
      content += '<div class="link_empty">'
      content += link_to_wishlist_empty(mini)
      content += '</div>'
      content += '<div class="link_send">'
      content += link_to_send_wishlist(mini)
      content += '</div>'
    end
    content += "<div class='clear'></div>"
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:name</tt> - name, <i>image_tag('forgeos_commerce/remove_product.gif')</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'wishlist', :action => 'empty'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_wishlist_remove_product(product, mini=false, name=image_tag('forgeos_commerce/remove_product.gif'), options={:confirm => I18n.t(:confirm_remove_product)})
    if mini
      link_to_remote(name,{ :url=>{:controller => 'wishlist', :action => 'remove_product', :id => product}, :update => 'wishlist' }.merge(options))
    else
      link_to(name, {:controller => 'wishlist', :action => 'remove_product', :id => product}, options)
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i>
  #
  # ==== Parameters
  # * <tt>:name</tt> - name
  # * <tt>:url</tt> - url, <i>{:controller => 'wishlist', :action => 'empty'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_wishlist_empty(mini=false,name=I18n.t('empty_wishlist').capitalize, url={:controller => 'wishlist', :action => 'empty'}, options={:confirm => I18n.t(:confirm_empty_wishlist)})
    if mini
      link_to_remote name, { :update => 'wishlist', :url => url }.merge(options)
    else
      link_to name, url, options
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i>
  #
  # ==== Parameters
  # * <tt>:name</tt> - name, <i>"Wishlist"</i> by default
  # * <tt>:url</tt> - url, <i>{:controller => 'wishlist'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_wishlist(name=I18n.t('wishlist',:count => 1), url={:controller => 'wishlist'}, options=nil)
    wishlist = Wishlist.find_by_id(session[:wishlist_id])
    unless wishlist.nil?
      name = "#{name} (#{wishlist.size} #{I18n.t('product', :count => wishlist.size)})"
    end
    link_to name.capitalize, {:controller => 'wishlist'}, options
  end

  def link_to_send_wishlist(mini=false,name=I18n.t('wishlist.send.friend').capitalize, url={:controller => 'wishlist', :action => 'send_to_friend'}, options={})
    if mini
      link_to_remote name.capitalize, { :method => :get, :update => 'wishlist', :url => url }.merge(options)
    else
      link_to name.capitalize, url, options
    end
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:name</tt> - name, <i>
  # * <tt>:url</tt> - url, <i>{:controller => 'wishlist', :action => 'add_product'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_add_wishlist(product, name='add_to_wishlist', url={:controller => 'wishlist', :action => 'add_product'}, options=nil)
    link_to I18n.t(name).capitalize, url.merge({:id => product.id}), options
  end
end
