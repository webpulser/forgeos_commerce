require 'ruleby'
class ShippingMethod < Ruleby::Rulebook

  attr_writer :shipping_ids
  
  def rules
    ShippingMethodRule.find_all_by_active(true).each do |shipping_method|
      rule eval(shipping_method.conditions) do |context|
          @shipping_ids << shipping_method.id
      end
    end
    @shipping_ids
  end
end
