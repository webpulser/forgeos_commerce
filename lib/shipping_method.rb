require 'ruleby'
class ShippingMethod < Ruleby::Rulebook

  attr_writer :cart
  
  def rules
    ShippingMethodRule.find_all_by_active(true).each do |shipping_method|
      p "*"*200
      p shipping_method.conditions
      rule eval(shipping_method.conditions) do |context|
         p "test"*20
          @cart.discount= shipping_method.id

      end
    end
  end
end
