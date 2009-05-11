# Attributes of <i>Product</i>
class Attribute < ActiveRecord::Base
  belongs_to :attributes_group, :readonly => true
  has_and_belongs_to_many :product_details
  sortable_pictures
end
