# Attributes of <i>Product</i>
class AttributeValue < ActiveRecord::Base
  translates :name
  belongs_to :attribute, :readonly => true
  
  has_and_belongs_to_many_attachments
  has_and_belongs_to_many :products
  #validates_presence_of :attribute_id
end
