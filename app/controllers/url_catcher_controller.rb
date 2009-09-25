class UrlCatcherController < ApplicationController
  def product
    @product = Product.find_by_url_and_deleted_and_active(params[:url],[false,nil],true)
    if @product && @product_category = @product.product_categories.first
      redirect_to(:controller => 'catalog', :id => @product.id, :categorie_name =>  @product_category.name)
    else
      redirect_to(:root)
    end
  end
end
