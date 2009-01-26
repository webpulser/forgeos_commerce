# Groups of <i>Attribute</i>
class AttributesGroup < ActiveRecord::Base

  has_many :tattributes, :class_name => 'Attribute', :dependent => :destroy
  has_and_belongs_to_many :products, :class_name => 'ProductParent', :readonly => true
  has_many :dynamic_attributes, :dependent => :destroy
  has_many :product_details, :through => :dynamic_attributes, :readonly => true
  has_many :sortable_pictures, :dependent => :destroy
  has_many :pictures, :through => :sortable_pictures, :readonly => true, :order => 'sortable_pictures.position'

  before_save :clear_attributes

private
  def clear_attributes
    self.tattributes.destroy_all if self.dynamic?
  end
end
