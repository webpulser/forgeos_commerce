class Admin::ImportController < Admin::BaseController
  before_filter :commerce_models, :only => :index

  map_fields :create_product, (ProductType.all.map(&:product_attributes).flatten.uniq.map(&:access_method) + Product.new.attributes.keys + Product.new.translated_attributes.stringify_keys.keys + Product.reflections.stringify_keys.keys).sort
  def create_product
    create_model(Product,'sku')
  end

  map_fields :create_product_type, (ProductType.new.attributes.keys + ProductType.new.translated_attributes.stringify_keys.keys).sort
  def create_product_type
    create_model(ProductType,'name')
  end

  map_fields :create_product_category, (ProductCategory.new.attributes.keys + ProductCategory.new.translated_attributes.stringify_keys.keys ).sort
  def create_product_category
    create_model(ProductCategory,'name')
  end

  map_fields :create_order, Order.new.attributes.keys.sort
  def create_order
    create_model(Order,'reference')
  end

  map_fields :create_order_detail, OrderDetail.new.attributes.keys.sort
  def create_order_detail
    create_model(OrderDetail,'sku')
  end

  map_fields :create_attribute_value, (AttributeValue.new.attributes.keys + AttributeValue.new.translated_attributes.stringify_keys.keys).sort
  def create_attribute_value
    create_model(AttributeValue,'name')
  end
  private

  def commerce_models
    @models << 'product' << 'product_type' << 'product_category' << 'order' << 'order_detail' << 'attribute_value'
  end
end
