class Admin::BaseController < ApplicationController
  layout 'admin'

private

  def initialize
    @content_for_tools = []
  end

end
