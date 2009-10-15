require 'ruleby'
class CatalogController < ApplicationController
  include Ruleby
  
  # Show all <i>ProductDetail</i>
  def index
    @product_category = params[:category_name] ? ProductCategory.find_by_name(params[:category_name]) : ProductCategory.first
    @product_categories = @product_category.children.collect{|c| c.id} if !@product_category.nil?
    @product_categories << @product_category.id if !@product_category.nil?
    @category_choice = params[:category_choice]
    
    if @category_choice.blank? || @category_choice == "0"
      @products = Product.all(:include => :product_categories,:conditions => {:active => true, :deleted=>[false, nil], :categories_elements=>{:category_id=>@product_categories}})
    else
      @category_choice = ProductCategory.find_by_id(@category_choice)
      @products = @category_choice.products.find_all_by_active(true)
    end
    
    if params[:url]
      @selected_product = Product.find_by_url(params[:url])
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
    respond_to do |format|
            format.html
            format.xml { render :xml => ProductCategory.find_all_by_parent_id(nil).to_xml }
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
 
end
