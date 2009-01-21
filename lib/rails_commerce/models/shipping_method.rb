module RailsCommerce
  class ShippingMethod < ActiveRecord::Base
    set_table_name "rails_commerce_shipping_methods"
    
    has_many :shipping_method_details, :class_name => 'RailsCommerce::ShippingMethodDetail'
  end
end
