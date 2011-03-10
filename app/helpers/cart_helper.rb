# Methods for display <i>Cart</i> (in totality, by product, ...).
module CartHelper
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
