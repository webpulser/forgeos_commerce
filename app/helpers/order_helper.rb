module OrderHelper
  def step_order(index=1)
    links = 
      link_to(image_tag(step_order_image_filename(1,index)), :controller => 'cart') <<
      link_to(image_tag(step_order_image_filename(2,index)), :controller => 'order', :action => 'informations') <<
      link_to(image_tag(step_order_image_filename(3,index)), :controller => 'order', :action => 'new') <<
      link_to(image_tag(step_order_image_filename(4,index)), :controller => 'order', :action => 'payment') <<
      link_to(image_tag(step_order_image_filename(5,index)), :controller => 'order', :action => 'confirmation')
    content_tag :div, links, :class => 'step_order'
  end

  def step_order_image_filename(step,index)
    "step#{step}_#{((index == step) ? 'on' : 'go')}_#{I18n.locale}.gif"
  end

  # Display a cart's product
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>carts_product</tt> a <i>CartsProduct</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order_by_carts_product(order, orders_detail)
    content_tag :div, :class => 'order_product_line' do
      content_tag :div, orders_detail.name, :class =>'order_name'
      content_tag :div, order_detail.quantity, :class => 'order_quantity'
      content_tag :div, orders_detail.price, :class => 'order_price'
      content_tag :div, orders_detail.total_tax, :class => 'order_tax'
      content_tag :div, "#{orders_detail.total(true)} #{$currency.html}", :class => 'order_price'
    end
  end

  # Display all products lines
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order_all_products_lines(order)
    price = order.shipping_method_price.to_s
    if session[:order_voucher_ids]
      session[:order_voucher_ids].each do |voucher_id|
        voucher = Voucher.find(voucher_id)
        if voucher.offer_delivery
          price = 0
        end
      end
    end
    content = ""
    order.orders_details.each do |orders_detail|
      content += display_order_by_carts_product(order, orders_detail)
    end
    content += content_tag :div, order.order_shipping.name, :class=>'order_shipping_method'
    content += content_tag :div, "#{price} #{$currency.html}", :class=>'order_shipping_method_price'
    if order.voucher
      content += content_tag :div,
        "#{I18n.t('voucher', :count => 1)} : -#{order.voucher} #{order.voucher.percent} #{$currency.html}",
        :class => 'order_voucher'
    end
    content += content_tag :div, :class=>'order_total' do
      content_tag :b, "#{I18n.t('total').capitalize} : #{order.total(true)} #{$currency.html}"
    end
  end
  

  # Display a order
  #
  # == Parameters
  # * <tt>order</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order(order)
    content_tag :div, :class => 'orders' do
      content_tag :div, :class => 'order_detail' do
        content_tag :div, order.id, :class => 'order_name'
        content_tag :div, I18n.l(order.created_at), :class => 'order_name'
      end
      content_tag :div, '&nbsp;', :class => 'clear'
      content_tag :div, I18n.t('name').capitalize, :class => 'order_name'
      content_tag :div, I18n.t('quantity').capitalize, :class => 'order_name'
      content_tag :div, I18n.t('unit_price').capitalize, :class=>'order_name'
      content_tag :div, I18n.t('tax', :count => 1), :class=>'order_name'
      content_tag :div, I18n.t('total').capitalize, :class=>'order_name'
      content_tag :div, display_order_all_products_lines(order), :class => 'orders_details'
      content_tag :div, I18n.t(order.status), :class => 'order_status'
    end
    #content_tag :div, 'nbsp;' , :class => 'clear'
  end

  # Display all shipping methods available for cart
  def display_shipping_methods(cart=current_user.cart)
    content = '<div class="order_shipping_methods" id="order_shipping_methods">'
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
          offer_delivery = false
          if session[:order_voucher_ids]
            session[:order_voucher_ids].each do |voucher_id|
              voucher = Voucher.find(voucher_id)
              offer_delivery ||= voucher.offer_delivery
            end
          end
          unless offer_delivery
            content += "#{shipping_method_detail.price} #{$currency.html}"
          else  
            content += "<s>#{shipping_method_detail.price}</s> <b>0</b> #{$currency.html}"
          end
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
      content += "<div class='filters'>"
        if multiple_addresses
          content +="<div class='enhanced'>"
          content +="<label>Selectionnez une autre de vos adresses</label>"
          content += select_tag address.class.to_s.gsub('', '').underscore + '_id',
                          options_for_select(address.class.find_all_by_user_id(address.user_id).collect { |address_| [address_.designation, address_.id] }, address.id),
                          :onchange => remote_function(
                            :url => { :controller => 'order', :action => 'change_address' },
                            :with => "'id=' + this.value"
                          )
          content +="</div>"
        end
      content += "</div>"
      content += '<div class="order_address_update">'
        content += link_to_remote(I18n.t('update').capitalize, :url => { :controller => 'order', :action => 'update_address', :id => address })
      content += '</div>'
    content += '</div>'
  end

  # Display the voucher's form_tag or the activate voucher <i>session[:order_voucher_ids]</i>
  def display_voucher
    content = '<div class="order_voucher" id="order_voucher">'
    if session[:order_voucher_ids]
      session[:order_voucher_ids].each do |voucher_id|
        voucher = Voucher.find(voucher_id)
        content += "#{I18n.t('voucher', :count=>1)} #{voucher.name} : -" + voucher.value.to_s + 
        " #{(voucher.percent ? '%' : $currency.html)} " + link_to_remove_voucher(voucher.id) + '<br />'
      end
    end
    content += "#{I18n.t('voucher', :count=>1)} : " + 
    text_field_tag(:voucher_code, "", :id => 'voucher_code') + " " + 
    button_to_function(
      I18n.t('add').capitalize, 
      remote_function(
        :url => { :controller => 'order', :action => 'add_voucher' },
        :with => "'voucher_code='+$('#voucher_code').val()"
      )
    )
    content += '</div>'
  end

  # Display the order's total price
  def display_total
    content = '<div class="order_total">'
      content += I18n.t('total').upcase + " : <span class='order-total-price'><span id='order_total_price'></span>#{$currency.html}</span>"
      content += javascript_tag remote_function(:url => { :controller => 'order', :action => 'update_total' })
    content += '</div>'
  end

  # Extension of <i>link_to(name, options = {}, html_options = nil)</i> with a <i>Product</i> object of first parameter
  #
  # ==== Parameters
  # * <tt>:name</tt> - name, <i>
  # * <tt>:url</tt> - url, <i>{:controller => 'order', :action => 'remove_voucher'}</i> by default
  # * <tt>options</tt> the html options
  def link_to_remove_voucher(voucher_id, name='remove_voucher', url={:controller => 'order', :action => 'remove_voucher'}, options=nil)
    link_to_remote( I18n.t(name).capitalize, :url => url, :with => "'voucher_id=#{voucher_id}'", :html => options)
  end
end
