# Include this module in your controller
#
# ==== session's variables
# * <tt>session[:order_shipping_method_id]</tt> - an id of a <i>ShippingMethodDetail</i> choice by user
# * <tt>session[:order_voucher_ids]</tt> - an id of a <i>Voucher</i> using by user

require 'ruleby'
class OrderController < ApplicationController

  include Ruleby
  
  before_filter :can_create_order?, :only => :create
  before_filter :special_offer, :only => [:new, :create, :update_transporter]
  before_filter :voucher, :only =>[:new, :create, :update_transporter]
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
    
    session[:transporter_rule_id] = params[:transporter_rule_id] if params[:transporter_rule_id]
    @transporter = TransporterRule.find_by_id(session[:transporter_rule_id])

    unless @transporter or current_cart.free_shipping
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
    #valid_shipment(false)
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
        
    address_invoice = @address_invoice
    address_delivery = @address_delivery
    #shipping_method = @shipping_method
    if current_cart.free_shipping
      transporter_name = "Free shipping"
      transporter_price = 0
    else
      transporter_name = @transporter.name
      transporter_price = @transporter.variables
    end
    
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
      :order_shipping_attributes => { :name => transporter_name, :price =>  transporter_price},
      :reference              => current_cart.id,
      :voucher_discount => current_cart.voucher_discount_price,
      :special_offer_discount => current_cart.special_offer_discount_price,
      :order_details_attributes => current_cart.carts_products.collect do |cart_product|
        {
          :name => cart_product.product.name,
          :description => cart_product.product.description,
          :price => cart_product.product.price(false, false),
          :rate_tax => cart_product.product.rate_tax,
          :sku => cart_product.product.sku,
          :product_id => cart_product.product.id,
          :voucher_discount => cart_product.product.voucher_discount,
          :voucher_discount_price => cart_product.product.voucher_discount_price,
          :special_offer_discount => cart_product.product.special_offer_discount,
          :special_offer_discount_price => cart_product.product.special_offer_discount_price          
        }
      end
      )
    
    @free_product_ids.each do |product_id|
      product = Product.find_by_id(product_id)
      @order.order_details.create!(:name => product.name, :description => product.description, :price => 0, :rate_tax => 0, :sku => product.sku, :product_id => product.id, :discount => "free product", :discount_price => 0)
    end
    session.delete(:voucher_code) if session[:voucher_code]
    current_cart.destroy
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
    #special_offer
    transporter_price = 0    
    if session[:order_shipping_method_id]
      offer_delivery = false
      @transporter_rule = TransporterRule.find_by_id(session[:order_shipping_method_id])
      transporter_price = @transporter_rule.variables.to_f unless offer_delivery and @transporter_rule.nil?
    end
        
    
    order_total = current_cart.total + transporter_price

    render(:update) do |page|
      #page.replace_html('order_total_price', "#{order_total} #{current_currency.html}")
      page.replace_html('transporter_price', "#{current_cart.total + transporter_price} #{current_currency.html}")
      page.visual_effect :highlight, 'transporter_price'
      page.visual_effect :highlight, 'order_total_price'
    end
  end

  def update_transporter
    @transporter_rule = TransporterRule.find_by_id(params[:id])
    session[:order_shipping_method_id] = @transporter_rule.id if @transporter_rule
    shipping_methods
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
      page.replace_html("order", :partial => 'form_address', :locals => { :address => @address })
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
    current_cart = Cart.find_by_id(session[:cart_id])
    if current_cart.nil? || current_cart.carts_products.empty?
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

  # check special offer rules
  def special_offer
    begin
      engine :special_offer_engine do |e|
        rule_builder = SpecialOffer.new(e)
        rule_builder.cart = current_cart
        @free_product_ids = []
        rule_builder.free_product_ids = @free_product_ids
        rule_builder.rules
        current_cart.carts_products.each do |cart_product|
          e.assert cart_product.product
        end
        e.assert current_cart
        e.match
      end
    rescue Exception
    end
  end

  # check voucher rules
  def voucher
    begin
      engine :voucher_engine do |e|
        rule_builder = Voucher.new(e)
        rule_builder.cart = current_cart
        rule_builder.code = session[:voucher_code]
        rule_builder.free_product_ids = @free_product_ids
        rule_builder.rules
        current_cart.carts_products.each do |cart_product|
          e.assert cart_product.product
        end
        e.assert current_cart
        e.match
      end
    rescue Exception
    end
  end


  protected

    def shipping_methods
      @transporter_ids = []
      begin
        engine :transporter_engine do |e|

          rule_builder = Transporter.new(e)
          rule_builder.transporter_ids = @transporter_ids
          rule_builder.rules
          current_cart.carts_products.each do |cart_product|
            e.assert cart_product.product
          end
          e.assert current_cart
          e.match
        end
      rescue Exception
      end
    end
  
end
