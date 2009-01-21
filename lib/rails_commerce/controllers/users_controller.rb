module RailsCommerce
  module UsersController
    # Return an HTML form for describing the new account
    def new
      session[:redirect] = nil
    end

    # Return an HTML form for describing the edit user
    def edit
    end

    # Update user
    def update
      current_user.update_attributes(params[:user])
      if current_user.errors.empty?
        flash[:notice] = "Your account has been updated"
        if redirect = session[:redirect]
          session[:redirect] = nil
          redirect_to redirect
        else
          redirect_to_home
        end
      else
        flash[:error] = current_user.errors
        if redirect = session[:redirect]
          session[:redirect] = nil
          redirect_to redirect
        else
          render :action => 'new'
        end
      end
    end

    # Create user
    def create
      cookies.delete :auth_token
      @user = User.new(params[:user])
      @user.save
      if @user.errors.empty?
        self.current_user = @user
        flash[:notice] = "Thanks for signing up!"
        get_cart
        if redirect = session[:redirect]
          session[:redirect] = nil
          redirect_to redirect
        else
          redirect_to_home
        end
      else
        flash[:error] = @user.errors
        flash[:user] = @user
        if redirect = session[:redirect]
          session[:redirect] = nil
          redirect_to redirect
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
        flash[:notice] = "Signup complete!"
      end
      redirect_back_or_default('/')
    end

    # Show user's orders
    def orders
      @orders = current_user.orders
    end
  end
end