require 'ruleby'
class ProductsController < ApplicationController
  include Ruleby
  before_filter :get_product, :only => [ :show ]

private
  def get_product
    @product = Product.find_by_id(params[:id])
    return redirect_to_home if @product.nil?
    
    # check special offers
    engine :special_offer_engine do |e|
      rule_builder = SpecialOffer.new(e)
      rule_builder.rules
      e.assert @product
      e.match
    end
  end
end
