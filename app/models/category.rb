class Category < ActiveRecord::Base
  acts_as_tree
  
  has_and_belongs_to_many :products, :association_foreign_key => 'product_id'
  has_many :sortable_pictures, :dependent => :destroy, :as => :picturable
  has_many :pictures, :through => :sortable_pictures, :readonly => true, :order => 'sortable_pictures.position'

  # Returns the level of <i>Category</i>
  def level
    return self.ancestors.length
  end
end
