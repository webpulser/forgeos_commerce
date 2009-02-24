# Include this module in your controller
#
# ==== session's variables
# * <tt>session[:order_shipping_method_detail_id]</tt> - an id of a <i>ShippingMethodDetail</i> choice by user
# * <tt>session[:order_voucher_id]</tt> - an id of a <i>Voucher</i> using by user
class OrderController < ApplicationController

  before_filter :can_create_order?, :only => :create
  before_filter :get_cart, :only => :new
  # Save in session <i>address_invoice_id</i> and <i>address_delivery_id</i>.
  # Returns false if miss an address or if <i>shipping_method_detail</i> is not validate by user, returns true else
  def valid_shipment(action=true)
    session[:address_invoice_id] = params[:address_invoice_id] if params[:address_invoice_id]
    session[:address_delivery_id] = params[:address_delivery_id] if params[:address_delivery_id]
    @address_invoice = AddressInvoice.find_by_id(session[:address_invoice_id])
    @address_delivery = AddressDelivery.find_by_id(session[:address_delivery_id])

    # AddressInvoice and AddressDelivery is obligatory for valid an order
    if !@address_invoice || !@address_delivery
      flash[:warning] = I18n.t('address', :count=>2).capitalize
      redirect_to(:action => 'new')
      return false
    end

    # TODO - include ActiveShipping
    # ShippingMethodDetail is obligatory for valid an order
    @shipping_method_detail = ShippingMethodDetail.find_by_id(session[:order_shipping_method_detail_id])
    unless @shipping_method_detail
      flash[:warning] = I18n.t('shipping_method',:count=>1).capitalize
      redirect_to(:action => 'new')
      return false
    end

    redirect_to(:action => 'payment') if action
    return true
  end

  # Payment integration
  def payment
    # TODO - include ActiveMerchant
    valid_shipment(false)
  end

  # Subscribe or edit user's informations
  # Link render with partials of user's views
  # session[:redirect] is initialize with <i>{:controller => 'order', :action => 'new'}</i>
  def informations
    session[:redirect] = {:controller => 'order', :action => 'new'}
  end

  # Final step, this action is accessible only if <i>session[:order_confirmation]</i> is true
  def confirmation
    redirect_to(:action => 'payment') unless session[:order_confirmation]
    session[:order_confirmation] = nil
  end

  def new
    return redirect_to(:action => 'informations') unless current_user
  end

  def create
    valid = valid_shipment(false)
    return false unless valid

    address_invoice = @address_invoice.clone
    address_delivery = @address_delivery.clone
    shipping_method_detail = @shipping_method_detail

    voucher = Voucher.find_by_id(session[:order_voucher_id])

    address_invoice.update_attribute(:user_id, nil)
    address_delivery.update_attribute(:user_id, nil)

    @order = Order.create(
      :user_id                => current_user.id,
      :address_invoice_id     => address_invoice.id, 
      :address_delivery_id    => address_delivery.id,
      :shipping_method        => shipping_method_detail.name,
      :shipping_method_price  => shipping_method_detail.price(false),
      :voucher                => (voucher) ? voucher.value : nil
    )

    @cart.carts_products.each do |cart_product|
      product = cart_product.product
      @order.orders_details << OrdersDetail.create(:name => product.name, :description => product.description, :price => product.price(false, false), :rate_tax => product.rate_tax, :quantity => cart_product.quantity)
    end
    @cart.destroy
    flash[:notice] = I18n.t('thank_you').capitalize
    session[:order_confirmation] = true
    redirect_to(:action => 'confirmation')
  end

  def add_address
    render(:update) do |page|
      page.replace_html("order", :partial => 'form_address')
    end
  end

  def update_total
    total = current_user.cart.total(true)
    if session[:order_shipping_method_detail_id]
      total += ShippingMethodDetail.find_by_id(session[:order_shipping_method_detail_id]).price
    end
    if session[:order_voucher_id]
      total -= Voucher.find(session[:order_voucher_id]).value
    end

    render(:update) do |page|
      page.replace_html('order_voucher', display_voucher)
      page.replace_html("order_total_price", total)
      page.visual_effect :highlight, 'order_total_price'
    end
  end

  def add_voucher
    voucher = Voucher.find_by_code(params[:voucher_code])
    session[:order_voucher_id] = voucher.id if voucher && voucher.is_valid?(current_user.cart.total(true))
    update_total
  end

  def remove_voucher
    session[:order_voucher_id] = nil
    update_total
  end

  def update_shipping_method
    shipping_method_detail = ShippingMethodDetail.find_by_id(params[:id])
    session[:order_shipping_method_detail_id] = shipping_method_detail.id if shipping_method_detail
    update_total
  end

  # form to addresses
  def back_addresses
    render(:update) do |page|
      page.replace_html("order", :partial => 'new')
      page.replace_html("order_address_#{@address.class.to_s}", display_address(@address)) if @address
    end
  end

  # Change select_tag address
  def change_address
    @address = Address.find_by_id(params[:id])
    render(:update) do |page|
      page.replace_html("order_address_#{@address.class.to_s}", display_address(@address))
      page.visual_effect :highlight, "order_address_#{@address.class.to_s}"
    end
  end
  
  # Go to form address
  def update_address
    @address = Address.find_by_id(params[:id])
    render(:update) do |page|
      page.replace_html("order", :partial => 'form_address', :locals => { :address, @address })
    end
  end
  
  # Make or update Address and back to addresses
  def create_address
    @address = Address.find_by_id(params[:id])
    if @address
      @address.update_attributes(params[:address])
    else
      if current_user.addresses.size == 0
        [AddressDelivery, AddressInvoice].each do |type|
          current_user.addresses << type.create(params[:address])
        end
      else
        type = (params[:address][:kind] == 'AddressDelivery') ? AddressDelivery : AddressInvoice
        current_user.addresses << type.create(params[:address])
      end
    end
    back_addresses
  end

private
  def can_create_order?
    @cart = Cart.find_by_id(session[:cart_id])
    if @cart.nil? || @cart.carts_products.empty?
      flash[:error] = I18n.t('your_cart_is_empty').capitalize
      redirect_to_home
    end
  end

  # for an interface user-friendly...
  def must_to_be_logged
    unless logged_in?
      if flash.nil?
        flash[:warning] = I18n.t('you_must_be_connected').capitalize
      else
        flash[:error] = flash[:error]
        flash[:user] = flash[:user]
      end
      redirect_to(:action => 'informations')
    end
  end
end
