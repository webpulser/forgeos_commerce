class ShippingMethod < ActiveRecord::Base
  has_many :shipping_method_details
  validates_presence_of :name
end
