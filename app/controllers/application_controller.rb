class ApplicationController < ActionController::Base
  helper_method :current_cart, :current_wishlist, :current_currency
  # Change the currency
  def change_currency(currency_id)
    if currency = Currency.find_by_id(currency_id)
      session[:currency] = currency.id
    end
    redirect_to(:back)
  end

private

  # Generate a cart and save this in session and instance <i>@cart</i>.
  #
  # If <i>session[:cart_id]</i> existing, this method instance just <i>@cart</i>
  def current_cart
    return @cart if @cart
    session[:cart_id] = current_user.cart.id if session[:cart_id].nil? && logged_in? && !current_user.is_a?(Administrator) && current_user.cart
    @cart = Cart.find_by_id(session[:cart_id])
    # If current_cart is nil because a problem of session or db.
    # This recursive call method, risk of stack error if this problem persist.
    if @cart.nil?
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
    # Associate cart with user if he's logged
    @cart.update_attribute(:user_id, current_user.id) if logged_in?
    return @cart
  end

  def current_wishlist
    return @wishlist if @wishlist
    session[:wishlist_id] = current_user.wishlist.id if session[:wishlist_id].nil? && logged_in? && !current_user.is_a?(Administrator) && current_user.wishlist
    @wishlist = Wishlist.find_by_id(session[:wishlist_id])
    if @wishlist.nil?
      @wishlist = Wishlist.create
      session[:wishlist_id] = @wishlist.id
    end
    @wishlist.update_attribute(:user_id, current_user.id) if logged_in?
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

  def current_currency
    if Currency.table_exists?
      #TODO move default current to Setting
      if currency=(Currency.find_by_id(session[:currency]) || Currency.find_by_code('EUR'))
        $currency = currency
        session[:currency] = currency.id
        return currency
      end
    end
  end
end
