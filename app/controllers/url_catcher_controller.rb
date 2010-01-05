class UrlCatcherController < ApplicationController
  def product
    p "test"*100
    #@product = Product.find_by_url_and_deleted_and_active(params[:url],[false,nil],true,:joins => :globalize_translations)
    @product = Product.find_by_url(params[:url],:joins => :globalize_translations)
    @category_choice = ProductCategory.find_by_name(params[:category_choice],:joins => :globalize_translations) || ProductCategory.find_by_id(params[:category_choice])
    @product_category = ProductCategory.find_by_name(params[:category_name],:joins => :globalize_translations)

    p @product.nil?

    if @product
      if @category_choice
        redirect_to(catalog_selected_category_path(:url => @product.url, :category_name =>  @product_category.name, :category_choice => @category_choice.name))
      elsif @product_category
        redirect_to(catalog_path(:url => @product.url, :category_name =>  @product_category.name))
      else
        redirect_to(@product.public_url)
      end
    else
      redirect_to(:root)
    end
  end
end
