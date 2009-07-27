class UrlCatcherController < ApplicationController
  def product
    @product = ProductParent.find_by_url(params[:url], :include => ['product_details'])
    return redirect_to_home if @product.nil?

    init_session_for_product(@product, true)
    return render :template => 'product/show'
  end
end
