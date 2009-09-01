class Admin::BaseController < ApplicationController 
  skip_before_filter :get_cart, :get_wishlist
  skip_before_filter :set_currency, :only => :notifications
end
