class UrlCatcherController < ApplicationController
  def product
    @product = Product.find_by_url_and_deleted_and_active(params[:url],[false,nil],true)
    @category_choice = ProductCategory.find_by_name(params[:category_choice])
    if @product && @product_category = ProductCategory.find_by_name(params[:category_name])
      redirect_to(:controller => 'catalog', :action => 'index', :url => @product.url, :category_name =>  @product_category.name, :category_choice => @category_choice.name)
    else
      redirect_to(:root)
    end
  end
end
