# Include this module in your controller
#
# ==== session's variables
# * <tt>session[:order_shipping_method_id]</tt> - an id of a <i>ShippingMethodDetail</i> choice by user
# * <tt>session[:order_voucher_ids]</tt> - an id of a <i>Voucher</i> using by user

require 'ruleby'
class OrderController < ApplicationController

  include Ruleby

  before_filter :can_create_order?, :only => :create
  before_filter :get_cart, :only => [:new,:informations,:paye]
  before_filter :shipping_methods, :only => :new
  
  # Save in session <i>address_invoice_id</i> and <i>address_delivery_id</i>.
  # Returns false if miss an address or if <i>shipping_method</i> is not validate by user, returns true else
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
    # ShippingMethod is obligatory for valid an order
    @shipping_method = ShippingMethod.find_by_id(session[:order_shipping_method_id])
    unless @shipping_method
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


  ## TODO - check special offer !!! 
  def create
    valid = valid_shipment(false)
    return false unless valid
    
    address_invoice = @address_invoice
    address_delivery = @address_delivery
    shipping_method = @shipping_method
    @order = Order.create(
      :user_id                => current_user.id,
      :address_delivery_attributes => {
        :name => address_delivery.name,
        :firstname => address_delivery.firstname,
        :address => address_delivery.address,
        :address_2 => address_delivery.address_2,
        :zip_code => address_delivery.zip_code,
        :city => address_delivery.city, 
        :civility => address_delivery.civility,
        :country_id => address_delivery.country_id, 
        :designation => 'toto'
        },
      :address_invoice_attributes => {
        :name => address_invoice.name,
        :firstname => address_invoice.firstname,
        :address => address_invoice.address,
        :address_2 => address_invoice.address_2,
        :zip_code => address_invoice.zip_code,
        :city => address_invoice.city,
        :civility => address_invoice.civility,
        :country_id => address_invoice.country_id, 
        :designation => 'toto'
        },      
      :order_shipping_attributes => { :name => shipping_method.name, :price => shipping_method.price(false) },
      #:voucher                => (voucher) ? voucher.value : nil,
      #:transaction_number     => params[:trans],
      :reference              => @cart.id,
      :order_details_attributes => @cart.products.collect do |product|
        {
          :name => product.name,
          :description => product.description,
          :price => product.price(false, false),
          :rate_tax => product.rate_tax,
          :sku => product.sku,
          :product_id => product.id
        }
      end
      )
      
    p 'toto'*10
    p @order.inspect
    @cart.destroy
   # @order.pay! if params[:trans] && !params[:trans].blank?
    flash[:notice] = I18n.t('thank_you').capitalize
    session[:order_confirmation] = @order.id
    redirect_to(:action => 'payment')
  end

  def add_address
    render(:update) do |page|
      page.replace_html("order", :partial => 'form_address')
    end
  end

  def update_total
    vouchers = session[:order_voucher_ids].collect{|voucher_id| Voucher.find(voucher_id)} if session[:order_voucher_ids]
    total = current_user.cart.total(true)
    if session[:order_shipping_method_id]
      offer_delivery = false
      if vouchers
        vouchers.each do |voucher|
          offer_delivery ||= voucher.offer_delivery
        end
      end
      total += ShippingMethod.find_by_id(session[:order_shipping_method_id]).price unless offer_delivery
    end
    if vouchers
      vouchers.each do |voucher|
        total -= voucher.percent ? (voucher.value * total / 100) : voucher.value
      end
    end
    total = 0 if total < 0

    render(:update) do |page|
      page.replace_html('order_voucher', display_voucher)
      page.replace_html('order_transporters', display_transporters)
      page.replace_html("order_total_price", total)
      page.visual_effect :highlight, 'order_total_price'
    end
  end

  def add_voucher
    voucher = Voucher.find_by_code(params[:voucher_code])
    vouchers = session[:order_voucher_ids].collect{|voucher_id| Voucher.find(voucher_id)} if session[:order_voucher_ids] && session[:order_voucher_ids].count > 0
    if voucher && voucher.is_valid?(current_user.cart.total(true))
      unless vouchers && voucher.cumulable && vouchers.first.cumulable
        session[:order_voucher_ids] = [voucher.id]
      else
        vouchers << voucher unless vouchers.include? voucher
        vouchers = vouchers.sort_by{|voucher| (voucher.percent ? 100 : 0) + voucher.value}
        session[:order_voucher_ids] = vouchers.collect{|voucher| voucher.id}
      end
    end
    update_total
  end

  def remove_voucher
    session[:order_voucher_ids].delete_if{|voucher_id| voucher_id.to_s == params[:voucher_id]}
    update_total
  end

  def update_transporter
    shipping_method = ShippingMethod.find_by_id(params[:id])
    session[:order_shipping_method_id] = shipping_method.id if shipping_method
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
        #type = (params[:address][:kind] == 'AddressDelivery') ? AddressDelivery : AddressInvoice
        current_user.addresses << AddressDelivery.create(params[:address])
        current_user.addresses << AddressInvoice.create(params[:address])
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

  protected
    def shipping_rule
      engine :shipping_rule_engine do |e|
        rule_builder = ShippingRule.new(e)
        rule_builder.cart = @cart
        rule_builder.rules

          
      end
    end

  def shipping_methods

    engine :shipping_method_engine do |e|

      rule_builder = ShippingMethod.new(e)
      rule_builder.cart = @cart
      rule_builder.rules
      @cart.carts_products.each do |cart_product|
          p cart_product.product.product_type
        e.assert cart_product.product
      end
      e.assert @cart
      e.match
    end
    
  end
  
end
