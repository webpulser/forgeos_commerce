# Groups of <i>Attribute</i>
class AttributesGroup < ActiveRecord::Base

  sortable_pictures
  has_many :tattributes, :class_name => 'Attribute', :dependent => :destroy
  has_and_belongs_to_many :products, :class_name => 'ProductParent', :readonly => true
  has_many :dynamic_attributes, :dependent => :destroy
  has_many :product_details, :through => :dynamic_attributes, :readonly => true
  
  before_save :clear_attributes

private
  def clear_attributes
    self.tattributes.destroy_all if self.dynamic?
  end
end
