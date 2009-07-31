class Category < ActiveRecord::Base
  acts_as_tree
  
  has_and_belongs_to_many :products, :association_foreign_key => 'product_id'
  sortable_attachments
  
  validates_presence_of :name

  # Returns the level of <i>Category</i>
  def level
    return self.ancestors.length
  end
end
