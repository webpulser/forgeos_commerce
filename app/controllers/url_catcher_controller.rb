class UrlCatcherController < ApplicationController
  def product
    @product = Product.find_by_url(params[:url])
    return redirect_to_home if @product.nil?
    @product.product_viewed_counters.new.increment_counter
    return render :template => 'products/show'
  end
end
