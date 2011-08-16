class DynamicAttributeValue < ActiveRecord::Base
  translates :value
  belongs_to :dynamic_attribute, :class_name => 'Attribute', :foreign_key => 'attribute_id'
  belongs_to :product
end
