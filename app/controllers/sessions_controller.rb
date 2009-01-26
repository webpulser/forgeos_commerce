# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  def new
    session[:redirect] = nil
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      if redirect = session[:redirect]
        session[:redirect] = nil
        redirect_to redirect
      else
        redirect_to_home
      end
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "The email and/or password you entered is invalid."
      if redirect = session[:redirect]
        session[:redirect] = nil
        redirect_to redirect
      else
        redirect_to :action => 'new'
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to_home
  end
end
