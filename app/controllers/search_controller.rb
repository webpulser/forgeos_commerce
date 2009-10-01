class SearchController < ApplicationController
  after_filter :search_product, :only => :index
private
  def search_product
    @items << Product.search(session[:keyword])
  end
end