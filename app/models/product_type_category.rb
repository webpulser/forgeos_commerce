class ProductTypeCategory < Category
  has_and_belongs_to_many :product_types
  has_and_belongs_to_many :elements, :class_name => 'ProductType'
end
