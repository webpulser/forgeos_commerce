require 'ruleby'
class CatalogController < ApplicationController
  include Ruleby
  
  # Show all <i>ProductDetail</i>
  def index
    @product_category = params[:category_name] ? ProductCategory.find_by_name(params[:category_name]) : ProductCategory.first
    @product_categories = @product_category.children.collect{|c| c.id}
    @product_categories << @product_category.id
    @category_choice = params[:category_choice]
    
    if @category_choice.blank?
      @products = Product.all(:include => :product_categories,:conditions => {:deleted=>[false, nil], :product_categories_products=>{:product_category_id=>@product_categories}})
    else
      @category_choice = ProductCategory.find_by_id(@category_choice)
      @products = @category_choice.products.all
    end
    
    if params[:id]
      @selected_product = Product.find_by_id(params[:id])
    else
      @selected_product = @products.first
    end
    
    # rules
    engine :special_offer_engine do |e|
      @shop = true
      rule_builder = SpecialOffer.new(e)
      rule_builder.rules
      @products.each do |product|
        e.assert product
      end
      e.assert @selected_product if !@selected_product.nil?
      e.match
    end
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
