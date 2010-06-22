class ProductCategory < Category
  has_and_belongs_to_many :elements, :join_table => 'categories_elements', :foreign_key => 'category_id', :association_foreign_key => 'element_id', :class_name => 'Product'

  def total_elements_count_with_deleted
    return 0 if self.elements.empty? & children.empty?
    ([self.elements.find(:all, :conditions => { :deleted => false}).size] + children.collect(&:total_elements_count)).sum
  end
  alias_method_chain :total_elements_count, :deleted

end
