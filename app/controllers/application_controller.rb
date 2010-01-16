class ApplicationController < ActionController::Base
  before_filter :set_currency, :get_cart, :get_wishlist

  # Change the currency
  def change_currency(currency_id)
    # TODO - move this method in an appriate class or module.
    currency = Currency.find_by_id(currency_id)
    $currency = currency if currency # Security if currency_id don't exist
    session[:currency] = $currency.id
    redirect_to(:back)
  end

private

  # Generate a cart and save this in session and instance <i>@cart</i>.
  #
  # If <i>session[:cart_id]</i> existing, this method instance just <i>@cart</i>
  def get_cart
    return redirect_to(admin_root_path) if current_user.is_a?(Administrator)
    session[:cart_id] = current_user.cart.id if session[:cart_id].nil? && logged_in? && current_user.cart
    session[:cart_id] = Cart.create.id if session[:cart_id].nil?
    @cart = Cart.find_by_id(session[:cart_id])
    # If @cart is nil because a problem of session or db.
    # This recursive call method, risk of stack error if this problem persist.
    if @cart.nil?
      session[:cart_id] = nil
      get_cart
    end
    # Associate cart with user if he's logged
    @cart.update_attribute(:user_id, current_user.id) if logged_in? && @cart.user_id != current_user.id
    return @cart
  end

  # Generate a wishlist and save this in session and instance <i>@wishlist</i>.
  #
  # If <i>session[:wishlist_id]</i> existing, this method instance just <i>@wishlist</i>
  def get_wishlist
    session[:wishlist_id] = current_user.wishlist.id if session[:wishlist_id].nil? && logged_in? && current_user.wishlist
    session[:wishlist_id] = Wishlist.create.id if session[:wishlist_id].nil?
    @wishlist = Wishlist.find_by_id(session[:wishlist_id])
    # If @wishlist is nil because a problem of session or db.
    # This recursive call method, risk of stack error if this problem persist.
    if @wishlist.nil?
      session[:wishlist_id] = nil
      get_wishlist
    end
    # Associate wishlist with user if he's logged
    @wishlist.update_attribute(:user_id, current_user.id) if logged_in? && @wishlist.user_id != current_user.id
    return @wishlist
  end

  # A short cut for redirect user to the homepage
  def redirect_to_home
    # TODO - controller/action generalize.
    redirect_to :locale => params[:locale], :controller => 'home', :action => 'index'
  end

  # Redirect to new session page if user isn't logged
  def must_to_be_logged
    unless logged_in?
      flash[:warning] = "You must be connected"
      redirect_to new_person_session_path(:locale => params[:locale])
    end
  end

  def set_currency
    if Currency.table_exists?
      currency = Currency.find_by_id(session[:currency])
      currency = Currency.find_by_code('EUR') unless currency #Locale.active.currency_code
      $currency = currency if currency
      session[:currency] = $currency.id 
    end
  end
end
