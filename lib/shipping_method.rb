require 'ruleby'
class ShippingMethod < Ruleby::Rulebook

  attr_writer :cart
  
  def rules
    ShippingMethodRule.find_all_by_active(true).each do |shipping_method|
      rule eval(shipping_method.conditions) do |context|
          @cart.discount= shipping_method.variables
      end
    end
  end
end
