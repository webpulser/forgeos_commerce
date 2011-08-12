load File.join(Gem.loaded_specs['forgeos_cms'].full_gem_path, 'app', 'controllers', 'forgeos', 'application_controller.rb')

Forgeos::ApplicationController.class_eval do
  helper_method :current_currency, :current_cart, :current_wishlist
  # Change the currency
  def change_currency(currency_id)
    if currency = Currency.find_by_id(currency_id)
      session[:currency_id] = currency.id
    end
    redirect_to(:back)
  end

private

  # Generate a cart and save this in session and instance <i>@cart</i>.
  #
  # If <i>session[:cart_id]</i> existing, this method instance just <i>@cart</i>
  def current_cart
    return @cart if @cart
    @cart = Cart.find_by_id(session[:cart_id])

    @cart = current_user.cart if logged_in? &&
      !current_user.is_a?(Administrator) &&
      current_user.cart &&
      (@cart.nil? or (@cart and @cart.is_empty?))
    # If current_cart is nil because a problem of session or db.
    # This recursive call method, risk of stack error if this problem persist.
    @cart = Cart.create unless @cart
    # Associate cart with user if he's logged
    @cart.update_attribute(:user_id, current_user.id) if logged_in?
    session[:cart_id] = @cart.id
    return @cart
  end

  def current_wishlist
    return @wishlist if @wishlist
    @wishlist = Wishlist.find_by_id(session[:wishlist_id])

    @wishlist = current_user.wishlist if logged_in? &&
      !current_user.is_a?(Administrator) &&
      current_user.wishlist &&
      (@wishlist.nil? or (@wishlist and @wishlist.is_empty?))

    @wishlist = Wishlist.create unless @wishlist

    @wishlist.update_attribute(:user_id, current_user.id) if logged_in?
    session[:wishlist_id] = @wishlist.id
    return @wishlist
  end

  # A short cut for redirect user to the homepage
  def redirect_to_home
    # TODO - controller/action generalize.
    redirect_to(root_path(:locale => params[:locale]))
  end

  # Redirect to new session page if user isn't logged
  def must_to_be_logged
    unless logged_in?
      flash[:warning] = "You must be connected"
      redirect_to(forgeos_core.new_person_session_path(:locale => params[:locale]))
    end
  end

  def current_currency
    return @current_currency if @current_currency
    #TODO move default current to Setting
    if Currency.table_exists? and
      @current_currency = (Currency.find_by_id(session[:currency_id], :select => '`id`, `default`, `html`, `code`') ||
        Currency.find_by_code('EUR', :select => '`id`, `default`, `html`, `code`'))
      session[:currency_id] = @current_currency.id
      return @current_currency
    end
  end
end
