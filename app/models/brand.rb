class Brand < ActiveRecord::Base
  acts_as_commentable
  
  accepts_nested_attributes_for :comments
  belongs_to :picture
  belongs_to :vendor
  has_many :products
  belongs_to :product_type  
  

  #has_many :products, :dependent => :destroy
  #has_and_belongs_to_many :product_attributes, :class_name => 'Attribute', :readonly => true
  #has_and_belongs_to_many :dynamic_attributes, :class_name => 'Attribute', :readonly => true, :join_table => 'attributes_product_types', :association_foreign_key => 'attribute_id',
  #  :conditions => {:dynamic => true}

  #has_and_belongs_to_many :product_type_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'

  validates_presence_of :name

  define_index do
    indexes name, :sortable => true
  end

  # Set all Products dynamic_attributes on save
  #def before_save
  #  self.products.each do |product|
  #    product.dynamic_attributes = dynamic_attributes
  #  end
  #end
  
  
 
end
