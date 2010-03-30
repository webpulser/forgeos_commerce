class Admin::BaseController < ApplicationController 
  skip_before_filter :set_currency, :only => [:notifications, :url]
end
