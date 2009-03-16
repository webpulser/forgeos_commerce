class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  layout 'admin'

  before_filter :login_required, :except => [:login, :logout]
private

  def initialize
    @content_for_tools = []
  end

end
