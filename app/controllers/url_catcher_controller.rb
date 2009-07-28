class UrlCatcherController < ApplicationController
  def product
    @product = Product.find_by_url(params[:url])
    return redirect_to_home if @product.nil?
    return render :template => 'products/show'
  end
end
