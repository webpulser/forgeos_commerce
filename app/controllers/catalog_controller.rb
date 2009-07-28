class CatalogController < ApplicationController
  # Show all <i>ProductDetail</i>
  def index
    @products = Product.paginate(:all, :per_page => 8, :page => params[:page], :conditions => { :active => true, :deleted => false })
  end

  # Show all <i>ProductDetail</i> by <i>Category</i>
  #
  # ==== Parameters
  # * <tt>:id</tt> - an id of a <i>Category</i>
  def category
    @category = Category.find_by_id(params[:id])
    return redirect_to_home unless @category
    @products = @category.products

    render :action => 'index'
  end

  # Search <i>ProductDetail</i>
  #
  # keywords is save in 
  #
  # ==== Parameters
  # * <tt>:keywords</tt> - an id of a <i>Category</i>    
  def search
    keywords = params[:keywords] || session[:keywords]
    session[:keywords] = keywords

    @products = Product.search_paginate(keywords, params[:page])

    render :action => 'index'
  end
end
