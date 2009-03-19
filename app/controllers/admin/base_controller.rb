class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  layout 'admin'
  before_filter :login_required
private

  def initialize
    @content_for_tools = []
  end

  def redirect_to_home
    redirect_to(admin_account_path(self.current_user))
  end
end
