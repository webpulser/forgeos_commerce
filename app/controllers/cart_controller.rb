require 'ruleby'
class CartController < ApplicationController
  include Ruleby
  before_filter :get_cart
  before_filter  :get_cross_selling, :only => [ :index ]
  
  #after_filter :special_offer, :only => [:index]
  # Show <i>Cart</i>
  def index
    flash[:notice] = I18n.t(:your_cart_is_empty).capitalize if @cart.is_empty?
  end

  # Add a <i>Product</i> in <i>Cart</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def add_product
    reset_order_session
    if params[:quantity]
      params[:quantity].first.to_i.times do 
        flash[:notice] = I18n.t(:product_added).capitalize if @cart.add_product_id(params[:id])
      end
    else
      flash[:notice] = I18n.t(:product_added).capitalize if @cart.add_product_id(params[:id])
    end 
    redirect_to(:action => 'index')
    #dd
    #redirect_or_update
  end

  # Empty the <i>Cart</i>
  #
  def empty
    reset_order_session
    get_cart.to_empty
    flash[:notice] = I18n.t(:cart_is_empty).capitalize
    redirect_or_update
  end

  # Remove a <i>Product</i> of <i>Cart</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def remove_product
    reset_order_session
    #p "pouf"*10
    #puts params[:id]
    flash[:notice] = I18n.t(:product_has_been_remove).capitalize if @cart.remove_product(params[:id])
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
    @cart.set_quantity Product.find(params[:product_id]), params[:quantity]

    if request.xhr?
      render(:update) do |page|
        page.replace_html("forgeos_commerce_cart_products", display_cart_all_products_lines(@cart, false, params[:mini]))
        page.replace_html("forgeos_commerce_cart_link", link_to_cart)
        page.visual_effect :pulsate, 'forgeos_commerce_cart_link'
        page.visual_effect :highlight, 'forgeos_commerce_cart'
        page.replace_html("notice", '')
      end
    else
      redirect_to(:action => 'index')
    end
  rescue
    redirect_to(:action => 'index')   
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
  # SpecialOffers
    # delete free product already in cart and cart discount
    @cart.update_attributes!(:discount => nil, :percent => nil)
    free_products = @cart.carts_products.find_by_free(1)
    free_products.destroy if free_products
    engine :special_offer_engine do |e|
      rule_builder = SpecialOffer.new(e)
      rule_builder.cart = @cart
      rule_builder.rules
      @cart.carts_products.each do |cart_product|
        ## set the new_price to product price
        cart_product.update_attributes!(:new_price => cart_product.product.price)
        
        ## barcode is not save!!, it's only to have the carts_products_id in the rule 
        cart_product.product.barcode = cart_product.id
        e.assert cart_product.product if cart_product.free != 1
      end
      e.assert @cart
      e.match
    end
  end

  def get_cross_selling
    
    @cross_selling_products = []
    @cart.carts_products.group_by(&:product_id).each do |cart_product|
      product = cart_product[1].first.product
      product.cross_sellings.each do |cross_selling_product|
        @cross_selling_products << cross_selling_product
      end
    end

    # rules
    engine :special_offer_engine do |e|
      @shop = true
      rule_builder = SpecialOffer.new(e)
      rule_builder.rules
      @cross_selling_products.each do |product|
        e.assert product
      end
      e.match
    end
  end

end
