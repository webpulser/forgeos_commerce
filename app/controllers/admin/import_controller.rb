class Admin::ImportController < Admin::BaseController
  before_filter :commerce_models, :only => :index

  map_fields :create_product, Product.new.attributes.keys + Product.new.translated_attributes.stringify_keys.keys
  def create_product
    create_model(Product,'sku')
  end

  map_fields :create_product_type, ProductType.new.attributes.keys
  def create_product_type
    create_model(ProductType,'name')
  end

  map_fields :create_product_category, ProductCategory.new.attributes.keys + ProductCategory.new.translated_attributes.stringify_keys.keys
  def create_product_category
    create_model(ProductCategory,'name')
  end

  map_fields :create_order, Order.new.attributes.keys
  def create_order
    create_model(Order,'reference')
  end

  map_fields :create_order_detail, OrderDetail.new.attributes.keys
  def create_order_detail
    create_model(OrderDetail,'sku')
  end

  private

  def commerce_models
    @models << 'product' << 'product_type' << 'product_category' << 'order' << 'order_detail'
  end
end
