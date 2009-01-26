# Attributes of <i>Product</i>
class Attribute < ActiveRecord::Base
  belongs_to :attributes_group, :readonly => true
  has_many :sortable_pictures, :dependent => :destroy
  has_many :pictures, :through => :sortable_pictures, :dependent => :destroy, :readonly => true, :order => 'sortable_pictures.position'
end
