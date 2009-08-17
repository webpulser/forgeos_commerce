class Category < ActiveRecord::Base
  acts_as_tree
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  
  validates_presence_of :name

  # Returns the level of <i>Category</i>
  def level
    return self.ancestors.length
  end
end
