class Admin::BaseController < ApplicationController 
  skip_before_filter :get_cart, :get_wishlist
end
