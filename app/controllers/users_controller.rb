class UsersController < ApplicationController
  # Return an HTML form for describing the new account
  def new
    session[:redirect] = nil
  end

  # Return an HTML form for describing the edit user
  def edit
    render :layout => false
  end

  # Update user
  def update
    current_user.update_attributes(params[:user])
    if current_user.errors.empty?
      flash[:notice] = I18n.t('account_update_ok').capitalize
      if redirect = session[:redirect]
        session[:redirect] = nil
        redirect_to(redirect)
      else
        redirect_to_home
      end
    else
      flash[:error] = current_user.errors
      if redirect = session[:redirect]
        session[:redirect] = nil
        redirect_to(redirect)
      else
        render :action => 'new'
      end
    end
    render :layout => false
  end

  # Create user
  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      flash[:notice] = I18n.t('account_creation_ok').capitalize
      get_cart
      if redirect = session[:redirect]
        session[:redirect] = nil
        redirect_to(redirect)
      else
        redirect_to_home
      end
    else
      flash[:error] = @user.errors
      flash[:user] = @user
      if redirect = session[:redirect]
        session[:redirect] = nil
        redirect_to(redirect)
      else
        render :action => 'new'
      end
    end
  end

  # Activate user
  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = I18n.t('signup_completed').capitalize
    end
    redirect_back_or_default('/')
  end

  # Show user's orders
  def orders
    @orders = current_user.orders
  end
end
