class CartController < ApplicationController
  before_filter :get_cart
  # Show <i>Cart</i>
  #
  # A <i>flash[:notice]</i> is create (<i>RailsCommerce::OPTIONS[:text][:your_cart_is_empty]</i>) if the <i>Cart</i> is empty.
  def index
    flash[:notice] = RailsCommerce::OPTIONS[:text][:your_cart_is_empty] if @cart.is_empty?
  end

  # Add a <i>Product</i> in <i>Cart</i>
  #
  # A <i>flash[:notice]</i> is create (<i>RailsCommerce::OPTIONS[:text][:product_added]</i>) if the <i>Product</i> is added.
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def add_product
    reset_order_session
    flash[:notice] = RailsCommerce::OPTIONS[:text][:product_added] if get_cart.add_product_id(params[:id])
    redirect_to :action => 'index'
  end

  # Empty the <i>Cart</i>
  #
  # A <i>flash[:notice]</i> is create (<i>RailsCommerce::OPTIONS[:text][:cart_is_empty]</i>).
  def empty
    reset_order_session
    get_cart.to_empty
    flash[:notice] = RailsCommerce::OPTIONS[:text][:cart_is_empty]
    redirect_to :action => 'index'
  end

  # Remove a <i>Product</i> of <i>Cart</i>
  #
  # A <i>flash[:notice]</i> is create (<i>RailsCommerce::OPTIONS[:text][:product_has_been_remove]</i>) if <i>Product</i> is removed
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def remove_product
    reset_order_session
    flash[:notice] = RailsCommerce::OPTIONS[:text][:product_has_been_remove] if @cart.remove_product_id(params[:id])
    redirect_to :action => 'index'
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
              page.replace_html("rails_commerce_cart_products", display_cart_all_products_lines(@cart))
              page.replace_html("rails_commerce_cart_link", link_to_cart)
              page.visual_effect :pulsate, 'rails_commerce_cart_link'
              page.visual_effect :highlight, 'rails_commerce_cart'
        page.replace_html("notice", '')
              end
              else
                redirect_to :action => 'index'
    end
  rescue
              redirect_to :action => 'index'      
  end

protected
  # Update <i>session[:order_shipping_method_detail_id]</i> and <i>session[:order_voucher_id]</i> at <i>nil</i>
  #
  # User must again valid the shipping method and his voucher if his <i>Cart</i> is updated
  def reset_order_session
    session[:order_shipping_method_detail_id] = session[:order_voucher_id] = nil
  end
end
