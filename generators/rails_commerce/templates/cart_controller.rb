# This controller handles the login/logout function of the site.  
class <%= controller_class_name %>Controller < ApplicationController
  include RailsCommerce::CartController
  before_filter :get_cart
end
