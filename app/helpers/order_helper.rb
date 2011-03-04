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
    "front_demo/steps/step#{step}_#{((index == step) ? 'on' : 'go')}_#{I18n.locale}.gif"
  end

  # Display a cart's product
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>carts_product</tt> a <i>CartsProduct</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order_by_carts_product(order, order_detail)
    content_tag :div, :class => 'order_product_line' do
      content_tag :div, order_detail.name, :class =>'order_name'
      content_tag :div, order_detail.quantity, :class => 'order_quantity'
      content_tag :div, order_detail.price, :class => 'order_price'
      content_tag :div, order_detail.total_tax, :class => 'order_tax'
      content_tag :div, "#{order_detail.total(true)} #{current_currency.html}", :class => 'order_price'
    end
  end

  # Display all products lines
  #
  # == Parameters
  # * <tt>cart</tt> a <i>Cart</i> object
  # * <tt>static</tt> add action's buttons for edit this cart if true, false by default
  def display_order_all_products_lines(order)
    price = order.shipping_method.to_s
    if session[:order_voucher_ids]
      session[:order_voucher_ids].each do |voucher_id|
        voucher = Voucher.find(voucher_id)
        if voucher.offer_delivery
          price = 0
        end
      end
    end
    content = ""
    order.order_details.each do |order_detail|
      content += display_order_by_carts_product(order, order_detail)
    end
    content += content_tag :div, order.order_shipping.name, :class=>'order_transporter'
    content += content_tag :div, "#{price} #{current_currency.html}", :class=>'order_transporter_price'
    if order.voucher
      content += content_tag :div,
        "#{I18n.t('voucher', :count => 1)} : -#{order.voucher} #{order.voucher.percent} #{current_currency.html}",
        :class => 'order_voucher'
    end
    content += content_tag :div, :class=>'order_total' do
      content_tag :b, "#{I18n.t('total').capitalize} : #{order.total(true)} #{current_currency.html}"
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
      content_tag :div, display_order_all_products_lines(order), :class => 'order_details'
      content_tag :div, I18n.t(order.status), :class => 'order_status'
    end
    #content_tag :div, 'nbsp;' , :class => 'clear'
  end

  # Display all shipping methods available for cart
  def display_transporters()
    content = '<div class="order_transporters" id="order_transporters">'

    @transporter_ids.each do |transporter_id|

      transporter = TransporterRule.find_by_id(transporter_id)

      content += '<div class="order_shipping_method">'
        content += '<span class="order_shipping_method_name">'
          content += radio_button_tag(
              'transporter_rule_id',
              transporter.id,
              (transporter.id == current_currency.options[:transporter_rule_id]),
              :onclick => remote_function(
              :url => { :action => 'update_transporter', :id => transporter.id }
              )
            )
          content += transporter.name.nil? ? transporter.parent.name : transporter.name
          content += " (#{transporter.variables} #{current_currency.html})"
        content += '</span>'

        content += '<div class="order_shipping_method_description">'
          content += transporter.description.nil? ? transporter.parent.description : transporter.description
        content += '</div>'
      content += '</div>'

    end

    content += '</div>'
  end

  # Display user's addresses choice
  def display_address(address, multiple_addresses=true, update=true)
    return unless address
    content = '<div class="display_address" id="order_address_' + address.class.to_s + '">'
      content += hidden_field_tag(address.class.to_s.gsub('', '').underscore + '_id',address.id)
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
      if address.country && address.country.respond_to?('printable_name')
        content += '<div class="address_country">'
          content += "#{address.country.printable_name}"
        content += '</div>'
      end
      content += "<div class='filters'>"
        if multiple_addresses
          content +="<div class='enhanced'>"
          content +="<label>Selectionnez une autre de vos adresses</label>"
          content += select_tag address.class.to_s.gsub('', '').underscore + '_id',
                          options_for_select(address.class.find_all_by_person_id(address.person_id).collect { |address_| [address_.designation, address_.id] }, address.id),
                          :onchange => remote_function(
                            :url => { :controller => 'order', :action => 'change_address' },
                            :with => "'id=' + this.value"
                          )
          content +="</div>"
        end
      content += "</div>"
      if update
        content += '<div class="order_address_update">'
          content += link_to_remote(I18n.t('update').capitalize, :url => { :controller => 'order', :action => 'update_address', :id => address })
        content += '</div>'
      end
    content += '</div>'
  end

  # Display the voucher's form_tag or the activate voucher
  def display_voucher
    content = '<div class="order_voucher" id="order_voucher">'

    content += "#{I18n.t('voucher', :count=>1)} : " +
    text_field_tag(:voucher_code, "", :id => 'voucher_code') + " " +
    button_to_function(
      I18n.t('add').capitalize,
      #:url => { :controller => 'order', :action => 'add_voucher' },
      remote_function(
        :url => { :controller => 'cart', :action => 'add_voucher'},
        :with => "'voucher_code='+$('#voucher_code').val()"
      )
    )

    content += '</div>'
  end

  # Display the order's total price
  def display_total
    content = '<div class="order_total">'
      content += I18n.t('total').upcase + " : <span class='order-total-price'><span id='order_total_price'></span>#{current_currency.html}</span>"
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
