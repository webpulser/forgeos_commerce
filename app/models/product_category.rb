class ProductCategory < Category
  has_and_belongs_to_many :products

  def total_products_count
    ([self.products.count] + children.collect(&:total_products_count)).inject(:+)
  end
end
