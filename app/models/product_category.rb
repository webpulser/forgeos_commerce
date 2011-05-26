class ProductCategory < Category
  has_and_belongs_to_many :elements, :join_table => 'categories_elements', :foreign_key => 'category_id', :association_foreign_key => 'element_id', :class_name => 'Product', :list => true

  def total_elements_count_with_deleted
    ([self.elements.count('id',:conditions => { :deleted => false})] + children.all(:select => 'id,type').map(&:total_elements_count)).sum
  end
  alias_method_chain :total_elements_count, :deleted

end
