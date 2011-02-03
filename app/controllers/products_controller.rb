require 'ruleby'
class ProductsController < ApplicationController
  include Ruleby
  before_filter :get_product, :only => [ :show ]
  caches_page :show, :if => :get_product

  # TEST only use for mobile application
  def index
    @products = Product.all(:conditions => {:deleted => [false, nil],:active => true})
    @products.each do |product|
      product.url = product.pictures.first.public_filename(:thumb) if !product.pictures.blank?
    end
    respond_to do |format|
            format.html
            format.xml { render :xml => @products.to_xml }
            format.json { render :json => @products.to_json }
    end
  end

private
  def get_product
    @product = Product.find_by_id(params[:id]) || Product.find_by_url(params[:url])
    return redirect_to_home if @product.nil?
    return false if request.format == 'js'

    # check special offers
    engine :special_offer_engine do |e|
      rule_builder = SpecialOffer.new(e)
      rule_builder.rules
      e.assert @product
      e.match
    end
  end
end
