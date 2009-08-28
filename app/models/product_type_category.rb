class ProductTypeCategory < Category
  has_and_belongs_to_many :product_types
end