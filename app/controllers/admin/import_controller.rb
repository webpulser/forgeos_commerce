class Admin::ImportController < Admin::BaseController
  before_filter :commerce_models, :only => :index

  map_fields :create_product, (Product.new.attributes.keys + Product.reflections.stringify_keys.keys + ProductType.all.map(&:product_attributes).flatten.uniq.map(&:access_method)).sort
  def create_product
    create_model(Product,'sku')
  end

  map_fields :create_order, Order.new.attributes.keys
  def create_order
    create_model(Order,'reference')
  end

  private

  def commerce_models
    @models << 'product' << 'order'
  end
end
