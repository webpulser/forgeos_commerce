class UrlCatcherController < ApplicationController
  def product
    @product = Product.find_by_url(params[:url])
    return redirect_to_home if @product.nil?
    counter = @product.product_viewed_counters.new
    unless counter.increment_counter
      counter.save
    end
    return render :template => 'products/show'
  end
end
