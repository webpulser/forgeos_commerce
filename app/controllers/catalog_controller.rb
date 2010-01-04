require 'ruleby'
class CatalogController < ApplicationController
  include Ruleby
  
  # Show all <i>ProductDetail</i>
  def index
    @product_category = ProductCategory.find_by_name(params[:category_name]) || ProductCategory.first
    
    #category_choice_id = params[:category_choice]
    @category_choice = ProductCategory.find_by_name(params[:category_choice]) || ProductCategory.find_by_id(params[:category_choice])
    unless @category_choice.nil?
      @product_categories = @category_choice.children.collect{|c| c.id} 
      @product_categories << @category_choice.id
    else
      @product_categories = @product_category.children.collect{|c| c.id}
      @product_categories << @product_category.id
    end
        
    @products = Product.all(:include => :product_categories,:conditions => {:active => true, :deleted=>[false, nil], :categories_elements=>{:category_id=>@product_categories}})
    
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
