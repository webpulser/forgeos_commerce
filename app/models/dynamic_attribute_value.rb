class DynamicAttributeValue < ActiveRecord::Base
  belongs_to :dynamic_attribute, :class_name => 'Attribute', :foreign_key => 'attribute_id'
  belongs_to :product
  
  validate_presence_of :product_id, :attribute_id, :value
end
