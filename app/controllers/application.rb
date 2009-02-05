# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time

  before_filter :set_locale, :set_currency
  # Change the currency
  def change_currency(currency_id)
    # TODO - move this method in an appriate class or module.
    currency = RailsCommerce::Currency.find_by_id(currency_id)
    $currency = currency if currency # Security if currency_id don't exist
    session[:currency] = $currency.id
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

  def set_currency
    if Currency.table_exists?
      currency = Currency.find_by_id(session[:currency])
      currency = Currency.find_by_code('EUR') unless currency #Locale.active.currency_code
      $currency = currency if currency
      session[:currency] = $currency.id 
    end
  end

  def set_locale
    if !params[:locale].nil? && LOCALES.keys.include?(params[:locale])
      if session[:locale] != params[:locale]
        session[:locale] = params[:locale]
      end
    elsif !session[:locale]
      session[:locale] = I18n.default_locale
    end
    I18n.locale = session[:locale]
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '3ed30cea0de1b40821196f7ca4414b19'
end
