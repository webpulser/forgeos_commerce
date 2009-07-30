class ShippingMethod < ActiveRecord::Base
  sortable_attachments
  has_many :shipping_method_details
  validates_presence_of :name
end
