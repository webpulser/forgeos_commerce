class ApplicationController < ActionController::Base
  helper_method :current_currency, :current_cart
  
  # Change the currency
  def change_currency(currency_id)
    if currency = Currency.find_by_id(currency_id)
      session[:currency] = currency.id
    end
    redirect_to(:back)
  end

private

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
  
end
