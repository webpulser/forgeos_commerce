module RailsCommerce
  class DynamicAttribute < ActiveRecord::Base
    set_table_name 'rails_commerce_dynamic_attributes'
    belongs_to :attributes_group, :class_name => 'RailsCommerce::AttributesGroup'
    belongs_to :product_detail, :class_name => 'RailsCommerce::ProductDetail'
  end
end
