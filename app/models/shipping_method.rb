class ShippingMethod < ActiveRecord::Base
  has_many :shipping_method_details
end
