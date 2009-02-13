module OrderHelper
  # Display a cart's product
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>carts_product</tt> a <i>CartsProduct</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order_by_carts_product(order, orders_detail)
    content = '<div class="order_product_line">'
      content += '<div class="order_name">'
        content += orders_detail.name
      content += '</div>'
      content += '<div class="order_quantity">'
        content += orders_detail.quantity.to_s
      content += '</div>'
      content += '<div class="order_price">'
        content += orders_detail.price.to_s
      content += '</div>'
      content += '<div class="order_tax">'
        content += orders_detail.total_tax.to_s
      content += '</div>'
      content += '<div class="order_price">'
        content += orders_detail.total(true).to_s + ' ' + $currency.html
      content += '</div>'
    content += '</div>'
  end

  # Display all products lines
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order_all_products_lines(order)
    content = ""
    order.orders_details.each do |orders_detail|
      content += display_order_by_carts_product(order, orders_detail)
    end
    content += '<div class="order_shipping_method">'
      content += order.shipping_method
    content += '</div>'
    content += '<div class="order_shipping_method_price">'
      content += order.shipping_method_price.to_s + ' ' + $currency.html
    content += '</div>'
    if order.voucher
      content += '<div class="order_voucher">'
        content += I18n.t('voucher',:count=>1) + ': -'
        content += order.voucher.to_s + ' ' + $currency.html
      content += '</div>'
    end
    content += '<div class="order_total"><b>'+ I18n.t('total').capitalize + ': </b>'
    content += order.total(true).to_s + ' ' + $currency.html
    content += '</div>'
  end
  

  # Display a order
  #
  # == Parameters
  # * <tt>order</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order(order)
    content = '<div class="orders">'
      content += '<div class="order_detail">'
        content += "<div class=\"order_name\">#{order.id}</div>"
        content += "<div class=\"order_name\">#{I18n.l order.created_at}</div>"
      content += '</div>'
      content += '<div class="clear">&nbsp;</div>'
      content += "<div class=\"order_name\">#{I18n.t('name').capitalize}</div>"
      content += "<div class=\"order_name\">#{I18n.t('quantity').capitalize}</div>"
      content += "<div class=\"order_name'>#{I18n.t('unit_price').capitalize}</div>"
      content += "<div class=\"order_name'>#{I18n.t('tax', :count => 1)}</div>"
      content += "<div class=\"order_name'>#{I18n.t('total').capitalize}</div>"
      content += '<div class="orders_details">'
        content += display_order_all_products_lines(order)
      content += '</div>'
      content += '<div class="order_status">'
        content += I18n.t(order.status)
      content += '</div>'
    content += '</div>'
    content += '<div class="clear">&nbsp;</div>'
  end

  # Display all shipping methods available for cart
  def display_shipping_methods(cart=current_user.cart)
    content = '<div class="order_shipping_methods">'
    if cart.get_shipping_method_details.empty?
      content += I18n.t('can_not_place_order')
    else
      cart.get_shipping_method_details.each do |shipping_method_detail|
        content += '<div class="order_shipping_method">'
          content += '<span class="order_shipping_method_name">'
            content += radio_button_tag(
                        'shipping_method_detail_id', 
                        shipping_method_detail.id, 
                        (shipping_method_detail.id == session[:order_shipping_method_detail_id]),
                        :onclick => remote_function(
                          :url => { :action => 'update_shipping_method', :id => shipping_method_detail.id }
                        )
                      )
            content += shipping_method_detail.fullname
          content += '</span>'
          content += '<span class="order_shipping_method_price">'
            content += "#{shipping_method_detail.price} #{$currency.html}"
          content += '</span>'

          content += '<div class="order_shipping_method_description">'
            content += shipping_method_detail.shipping_method.description
          content += '</div>'
        content += '</div>'
      end
    end
    content += '</div>'
  end

  # Display user's addresses choice
  def display_address(address, multiple_addresses=true)
    return unless address
    content = '<div class="display_address" id="order_address_' + address.class.to_s + '">'
      content += '<div class="order_address_update">'
        content += link_to_remote(I18n.t('update').capitalize, :url => { :controller => 'order', :action => 'update_address', :id => address })
      content += '</div>'

      if multiple_addresses
        content += select_tag address.class.to_s.gsub('', '').underscore + '_id', 
                        options_for_select(address.class.find_all_by_user_id(address.user_id).collect { |address_| [address_, address_.id] }, address.id), 
                        :onchange => remote_function(
                          :url => { :controller => 'order', :action => 'change_address' }, 
                          :with => "'id=' + this.value"
                        )
      end

      content += '<div class="address_name">'
        content += "#{address.name} #{address.firstname}"
      content += '</div>'
      content += '<div class="address_address">'
        content += address.address
        unless address.address_2.blank?
          content += "<br />#{address.address_2}"
        end
      content += '</div>'
      content += '<div class="address_city">'
        content += "#{address.zip_code} #{address.city}"
      content += '</div>'
    content += '</div>'
  end

  # Display the voucher's form_tag or the activate voucher <i>session[:order_voucher_id]</i>
  def display_voucher
    content = '<div class="order_voucher" id="order_voucher">'
    if session[:order_voucher_id]
      content += "#{I18n.t('voucher', :count=>1)} : -" + Voucher.find(session[:order_voucher_id]).value.to_s + 
      " #{$currency.html} " + link_to_remove_voucher
    else
      content += "#{I18n.t('voucher', :count=>1)} : " + 
      text_field_tag(:voucher_code, "", :id => 'voucher_code') + " " + 
      button_to_function(
        I18n.t('add').capitalize, 
        remote_function(
          :url => { :controller => 'order', :action => 'add_voucher' },
          :with => "'voucher_code='+$('#voucher_code').val()"
        )
      )
    end
    content += '</div>'
  end

  # Display the order's total price
  def display_total
    content = '<div class="order_total">'
      content += I18n.t('total').upcase + " : <span id='order_total_price'></span> #{$currency.html}"
      content += javascript_tag remote_function(:url => { :controller => 'order', :action => 'update_total' })
    content += '</div>'
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:name</tt> - name, <i>
  # * <tt>:url</tt> - url, <i>{:controller => 'order', :action => 'remove_voucher'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_remove_voucher(name='remove_voucher', url={:controller => 'order', :action => 'remove_voucher'}, options=nil)
    link_to_remote I18n.t(name).capitalize, :url => url, :html => options
  end
end
