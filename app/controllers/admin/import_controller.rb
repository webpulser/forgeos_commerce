class Admin::ImportController < Admin::BaseController
  map_fields :create_product, %w(sku* name* description price* url* stock weight Categories product_type*)
  before_filter :commerce_models, :only => :index

  def create_product
    create_model(Product,'sku') do |row|
      attributes = {} 
      %w(sku name description price url stock weight).each_with_index do |attribute,i|
        attributes[attribute.to_sym] = row[i] if row[i]
      end
      attributes[:product_type_id] = (ProductType.find_by_name(row[8]) || ProductType.first).id
      attributes[:category_ids] = ProductCategory.find_all_by_name(row[7].split(','), :select=>'id').map(&:id) if row[7]
      attributes
    end
  end

  private

  def commerce_models
    @models << 'product' << 'order'
  end
end
