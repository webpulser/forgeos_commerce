class CartController < ApplicationController
  before_filter :get_cart
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
    flash[:notice] = I18n.t(:product_added).capitalize if get_cart.add_product_id(params[:id])
    redirect_or_update
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
    flash[:notice] = I18n.t(:product_has_been_remove).capitalize if @cart.remove_product_id(params[:id])
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
    @cart.set_quantity ProductDetail.find(params[:product_id]), params[:quantity]

    if request.xhr?
      render(:update) do |page|
        page.replace_html("rails_commerce_cart_products", display_cart_all_products_lines(@cart, false, params[:mini]))
        page.replace_html("rails_commerce_cart_link", link_to_cart)
        page.visual_effect :pulsate, 'rails_commerce_cart_link'
        page.visual_effect :highlight, 'rails_commerce_cart'
        page.replace_html("notice", '')
      end
    else
      redirect_to(:action => 'index')
    end
  rescue
    redirect_to(:action => 'index')   
  end

protected
  # Update <i>session[:order_shipping_method_detail_id]</i> and <i>session[:order_voucher_id]</i> at <i>nil</i>
  #
  # User must again valid the shipping method and his voucher if his <i>Cart</i> is updated
  def reset_order_session
    session[:order_shipping_method_detail_id] = session[:order_voucher_id] = nil
  end

  def redirect_or_update
    unless request.xhr?
      redirect_to(:action => 'index') 
    else
      render :action => 'update_cart', :layout => false
    end
  end
end
