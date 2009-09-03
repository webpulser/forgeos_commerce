class ProductCategory < Category
  has_and_belongs_to_many :products
  has_and_belongs_to_many :elements, :class_name => 'Product'
end
