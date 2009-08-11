require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart
  def rules
    SpecialOfferRule.find_all_by_activated(true).each do |special_offer|
      rule eval(special_offer.conditions) do |context|
        
        # Discount product price
        product = context[:product]
        
        if special_offer.variables[:fixed_discount]
          rate = special_offer.variables[:discount]
          new_price = product.price - (special_offer.variables[:fixed_discount] ? rate : ((product.price * rate) / 100))
          puts @cart.add_new_price(product, new_price)
        end
        
        return true unless @cart
        
        # Free shippment
        @cart.free_shipping_method_detail_ids += special_offer.variables[:shipping_ids] if special_offer.variables[:shipping_ids]
        
        # Free products
        special_offer.variables[:product_ids].each do |product_id|
          @cart.add_product(Product.find(product_id),true) unless @cart.has_free_product?(product_id)
        end if special_offer.variables[:product_ids]
        
        retract product
      end
    end
  end
end
