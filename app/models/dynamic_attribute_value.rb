class DynamicAttributeValue < ActiveRecord::Base
  belongs_to :dynamic_attribute
  belongs_to :product
end
