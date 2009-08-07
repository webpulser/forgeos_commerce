require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart
  def rules
    SpecialOfferRule.find_all_by_activated(true).each do |special_offer|
      rule eval(special_offer.conditions) do |context|

        # Discount product price
        product = context[:product]
        rate = special_offer.variables[:discount]
        discount = rate.to_i
        if rate.is_a?(String) && discount != 0 && discount < 100
          product.price -= (product.price * discount) / 100
        elsif rate.is_a?(Fixnum) && rate < product.price
          product.price -= rate
        end
        retract product

        # Free shippment
        @cart.free_shipping_method_detail_ids +=
          special_offer.shipping_method_detail_ids if @cart
      end
    end
  end
end
