require 'ruleby'
class CartController < ApplicationController
  include Ruleby
  before_filter :get_cross_selling, :only => [:index]
  before_filter :check_voucher_code, :only => [:add_voucher]
  before_filter :special_offer, :only => [:index, :add_voucher]
  before_filter :voucher, :only => [:index, :add_voucher]
  
  # Show <i>Cart</i>
  def index
    flash[:notice] = t(:your_cart_is_empty).capitalize if current_cart.is_empty?    
  end

  # Add a <i>Product</i> in <i>Cart</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def add_product
    reset_order_session
    if params[:quantity]
      flash[:notice] = t(:product_added).capitalize if current_cart.add_product_id(params[:id],params[:quantity].to_i)
    else
      flash[:notice] = t(:product_added).capitalize if current_cart.add_product_id(params[:id])
    end 
    redirect_to(:action => 'index')
    #dd
    #redirect_or_update
  end

  # Empty the <i>Cart</i>
  #
  def empty
    reset_order_session
    current_cart.to_empty
    flash[:notice] = t(:cart_is_empty).capitalize
    redirect_or_update
  end

  # Remove a <i>Product</i> of <i>Cart</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def remove_product
    reset_order_session
    flash[:notice] = t(:product_has_been_remove).capitalize if current_cart.remove_product_id(params[:id])
    redirect_or_update
  end

  # Update quantity of a <i>Product</i>
  #
  # This action can be called in XHR or GET request.
  #
  # ==== Parameters
  # * <tt>:product_id</tt> - a <i>Product</i> object
  # * <tt>:quantity</tt> - a <i>Product</i> object
  def update_quantity
    reset_order_session
    cart_product = current_cart.carts_products.find_all_by_product_id(params[:product_id])
    quantity = params[:quantity].to_i
    old_quantity = cart_product.size
    if old_quantity < quantity
      current_cart.add_product_id(params[:product_id],quantity - old_quantity)
    else
      current_cart.remove_product_id(params[:product_id],old_quantity - quantity)
    end

    if request.xhr?
      render(:update) do |page|
        page.replace_html("forgeos_commerce_cart_products", display_cart_all_products_lines(current_cart, false, params[:mini]))
        page.replace_html("forgeos_commerce_cart_link", link_to_cart)
        page.visual_effect :pulsate, 'forgeos_commerce_cart_link'
        page.visual_effect :highlight, 'forgeos_commerce_cart'
        page.replace_html("notice", '')
      end
    else
      redirect_to(:action => 'index')
    end
  end
  
  def add_voucher
    voucher = VoucherRule.find_by_id(current_cart.voucher)    
    if voucher.nil?
      session.delete(:voucher_code) 
    else
      session[:voucher_code] = voucher.code
      render(:update) do |page|
        page.replace_html('voucher_message', "With voucher code #{voucher.code} : #{voucher.name}")
        page.replace_html('cart_total', price_with_currency(current_cart.total))
        page.visual_effect :highlight, 'cart_total'
      end
    end
  end
  
  
protected
  # Update <i>session[:order_shipping_method_id]</i> and <i>session[:order_voucher_ids]</i> at <i>nil</i>
  #
  # User must again valid the shipping method and his voucher if his <i>Cart</i> is updated
  def reset_order_session
    session[:order_shipping_method_id] = session[:order_voucher_ids] = nil
  end

  def redirect_or_update
    unless request.xhr?
      redirect_to(:action => 'index')
    else
      render :action => 'update_cart', :layout => false
    end
  end

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

  def check_voucher_code
    @voucher_code = params[:voucher_code] || session[:voucher_code]
    voucher = VoucherRule.find_all_by_active_and_code(true,@voucher_code)
    render(:update) do |page|
      page.replace_html('voucher_message', "Le code promo #{@voucher_code} est invalide")
      page.replace_html('cart_total', price_with_currency(current_cart.total))
      session.delete(:voucher_code) if session[:voucher_code]
    end if voucher.blank? or voucher.nil?
  end

  def voucher
    begin
      engine :voucher_engine do |e|
        rule_builder = Voucher.new(e)
        rule_builder.cart = current_cart
        rule_builder.code = @voucher_code || session[:voucher_code]
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

  def get_cross_selling
    
    @cross_selling_products = []
    current_cart.carts_products.group_by(&:product_id).each do |cart_product|
      if product = cart_product[1].first.product
        product.cross_sellings.each do |cross_selling_product|
          @cross_selling_products << cross_selling_product
        end
      end
    end

    # rules
    #engine :special_offer_engine do |e|
    #  @shop = true
    #  rule_builder = SpecialOffer.new(e)
    #  rule_builder.rules
    #  @cross_selling_products.each do |product|
    #    e.assert product
    #  end
    #  e.match
    #end
  end
end
