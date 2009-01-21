module RailsCommerce
  # This module must to be include in your <i>ApplicationController</i>
  module Application
    # Change the currency
    def change_currency(currency_id)
      # TODO - move this method in an appriate class or module.
      currency = RailsCommerce::Currency.find_by_id(currency_id)
      $currency = currency if currency # Security if currency_id don't exist
      redirect_to_home
    end

    # Generate a cart and save this in session and instance <i>@cart</i>.
    #
    # If <i>session[:cart_id]</i> existing, this method instance just <i>@cart</i>
    def get_cart
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

    # A short cut for redirect user to the homepage
    def redirect_to_home
      # TODO - controller/action generalize.
      redirect_to :locale => params[:locale], :controller => 'home', :action => 'index'
    end

    # Redirect to new session page if user isn't logged
    def must_to_be_logged
      unless logged_in?
        flash[:warning] = "You must be connected"
        redirect_to new_session_path(:locale => params[:locale])
      end
    end

    # Initialize user's language
    def set_locale
      if !params[:locale].nil? && LOCALES.include?(params[:locale])
        session[:locale] = params[:locale]
        if RailsCommerce::Currency.table_exists?
  #          currency = RailsCommerce::Currency.find_by_code(Locale.active.currency_code)
  #          $currency = currency if currency
        end
        I18n.locale = session[:locale] if session[:locale]
      else
        redirect_to params.merge( 'locale' => session[:locale] || I18n.default_locale )
      end
    end
  end
end