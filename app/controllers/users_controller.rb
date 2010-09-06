class UsersController < ApplicationController
  def show
    @user = User.find_by_id params[:id]
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml }
      format.json { render :json => @user.to_json }
    end
    
  end
  
  # Return an HTML form for describing the new account
  def new
    session[:return_to] = nil
  end

  # Return an HTML form for describing the edit user
  def edit
    render :layout => false
  end

  # Update user
  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = I18n.t('account_update_ok').capitalize
      if redirect = session[:return_to]
        session[:return_to] = nil
        return redirect_to(redirect)
      else
        return redirect_to_home
      end
    else
      flash[:error] = current_user.errors
      if redirect = session[:return_to]
        session[:return_to] = nil
        return redirect_to(redirect)
      else
        return render(:action => :new)
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
      #self.current_user = @user
      @user.activate
      
      PersonSession.create(@user, true)
      flash[:notice] = I18n.t('account_creation_ok').capitalize
      current_cart
      if redirect = session[:return_to]
        session[:return_to] = nil
        redirect_to(redirect)
      else
        redirect_to_home
      end
    else
      flash[:error] = @user.errors
      flash[:user] = @user
      if redirect = session[:return_to]
        session[:return_to] = nil
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
      UserMailer.deliver_activation(current_user)
      flash[:notice] = I18n.t('signup_completed').capitalize
    end
    redirect_back_or_default('/')
  end

  # Show user's orders
  def orders
    @orders = current_user.orders
  end
end
