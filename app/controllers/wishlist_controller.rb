class WishlistController < ApplicationController
  before_filter :login_required, :only => [:send_to_friend]
  # Show <i>Wishlist</i>
  def index
    flash[:notice] = I18n.t(:your_wishlist_is_empty).capitalize if current_wishlist.is_empty?
  end

  # Add a <i>Product</i> in <i>Wishlist</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def add_product
    reset_order_session
    flash[:notice] = I18n.t(:product_added).capitalize if current_wishlist.add_product_id(params[:id])
    redirect_or_update
  end

  # Empty the <i>Wishlist</i>
  #
  def empty
    reset_order_session
    current_wishlist.to_empty
    flash[:notice] = I18n.t(:wishlist_is_empty).capitalize
    redirect_or_update
  end

  # Remove a <i>Product</i> of <i>Wishlist</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - a <i>Product</i> object
  def remove_product
    reset_order_session
    flash[:notice] = I18n.t(:product_has_been_remove).capitalize if current_wishlist.remove_product_id(params[:id])
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
    current_wishlist.set_quantity Product.find(params[:product_id]), params[:quantity]

    if request.xhr?
      render(:update) do |page|
        page.replace_html("forgeos_commerce_wishlist_products", display_wishlist_all_products_lines(current_wishlist, false, params[:mini]))
        page.replace_html("forgeos_commerce_wishlist_link", link_to_wishlist)
        page.visual_effect :pulsate, 'forgeos_commerce_wishlist_link'
        page.visual_effect :highlight, 'forgeos_commerce_wishlist'
        page.replace_html("notice", '')
      end
    else
      redirect_to(:action => 'index')
    end
  rescue
    redirect_to(:action => 'index')   
  end

  def send_to_friend
    if request.post? && current_wishlist = Wishlist.find_by_id(session[:wishlist_id])
      UserMailer.deliver_wishlist(current_user,params[:email], current_wishlist)
      return redirect_to_home
    end
    render :layout => false if request.xhr?
  end

protected
  # Update <i>session[:order_shipping_method_id]</i> and <i>session[:order_voucher_ids]</i> at <i>nil</i>
  #
  # User must again valid the shipping method and his voucher if his <i>Wishlist</i> is updated
  def reset_order_session
    session[:order_shipping_method_id] = session[:order_voucher_ids] = nil
  end

  def redirect_or_update
    unless request.xhr?
      redirect_to(:action => 'index') 
    else
      render :action => 'update_wishlist', :layout => false
    end
  end
end
