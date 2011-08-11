load File.join(Gem.loaded_specs['forgeos_cms'].full_gem_path, 'app', 'controllers', 'admin', 'import_controller.rb')

Admin::ImportController.class_eval do
  before_filter :commerce_models, :only => :index

  map_fields :create_product, (Product.new.attributes.keys.sort + Product.new.translated_attributes.stringify_keys.keys.sort + ProductType.all.map(&:product_attributes).flatten.uniq.map(&:access_method).sort + Product.reflections.stringify_keys.keys.sort)
  def create_product
    create_model(Product,'sku') do |attributes|
      attributes[:category_ids] = attributes.delete(:categories) unless attributes[:categories].blank?
      attributes
    end
  end

  map_fields :create_brand, (Brand.new.attributes.keys.sort + Brand.reflections.stringify_keys.keys.sort)
  def create_brand
    create_model(Brand,'code') do |attributes|
      attributes[:category_ids] = attributes.delete(:categories) unless attributes[:categories].blank?
      attributes
    end
  end

  map_fields :create_product_type, (ProductType.new.attributes.keys + ProductType.new.translated_attributes.stringify_keys.keys).sort
  def create_product_type
    create_model(ProductType,'name')
  end

  map_fields :create_address, (Address.new.attributes.keys).sort
  def create_address
    create_model(Address,'person_id')
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
    @models << 'product' << 'product_type' << 'product_category' << 'order' << 'order_detail' << 'attribute_value' << 'address' << 'brand'
  end
end
