class ProductsController < ApplicationController
  before_filter :get_product, :only => [ :show ]

private
  def get_product
    @product = Product.find_by_id(params[:id])
    return redirect_to_home if @product.nil?
  end
end
