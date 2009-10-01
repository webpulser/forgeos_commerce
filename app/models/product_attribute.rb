class ProductAttribute < Attribute
  has_and_belongs_to_many :product_types, :readonly => true
  has_many :products, :through => :dynamic_attribute_values, :readonly => true
end
