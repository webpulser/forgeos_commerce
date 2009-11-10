# Attributes of <i>Product</i>
class AttributeValue < ActiveRecord::Base
  belongs_to :attribute, :readonly => true
  
  has_and_belongs_to_many :products
  #validates_presence_of :attribute_id
end
