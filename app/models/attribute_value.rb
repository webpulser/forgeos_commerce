# Attributes of <i>Product</i>
class AttributeValue < ActiveRecord::Base
  belongs_to :attribute, :readonly => true
  
  has_and_belongs_to_many :products
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
end
