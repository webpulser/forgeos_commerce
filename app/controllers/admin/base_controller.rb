class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  layout 'admin'
  before_filter :login_required
  skip_before_filter :get_cart, :get_wishlist
private

  def redirect_to_home
    redirect_to(admin_account_path(self.current_user))
  end
end
