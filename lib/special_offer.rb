require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart, :free_product_ids, :rule_id, :selected_products
  def rules
    if @rule_id
      rule_preview = SpecialOfferRule.find_by_id(@rule_id)
      rule eval(rule_preview.conditions) do |context|
        product = context[:product]
        @selected_products << product.id
      end
    else

      SpecialOfferRule.find_all_by_active(true).each do |special_offer|
        #puts special_offer.conditions
        rule eval(special_offer.conditions) do |context|
          product = context[:product]
          ## Product in Shop
          if @cart.nil?
            if special_offer.variables[:discount]
              rate = special_offer.variables[:discount]
              discount_price = special_offer.variables[:fixed_discount] ? rate : (product.price * rate) / 100
              product.special_offer_discount_price = discount_price
              special_offer.variables[:fixed_discount] ? product.special_offer_discount = "-#{rate}" : product.special_offer_discount = "-#{rate}%"
            end

          ## Product in cart OR cart
          else

            if special_offer.variables[:discount]
              rate = special_offer.variables[:discount]
              discount_price = special_offer.variables[:fixed_discount] ? rate : (product.price * rate) / 100
              product.special_offer_discount_price = discount_price
              special_offer.variables[:fixed_discount] ? product.special_offer_discount = "-#{rate}" : product.special_offer_discount = "-#{rate}%"
            end


            # Free products  --cart and product_in_cart
            special_offer.variables[:product_ids].each do |product_id|
              @free_product_ids << product_id
            end if special_offer.variables[:product_ids]

            # Discount cart total price  --cart
            if special_offer.variables[:cart_discount]
              rate = special_offer.variables[:cart_discount]
              discount_price = special_offer.variables[:fixed_discount] ? rate : (@cart.total * rate) / 100
              @cart.special_offer_discount_price = discount_price
              special_offer.variables[:fixed_discount]? @cart.special_offer_discount = "-#{rate}" : @cart.special_offer_discount = "-#{rate}%"
            end

            # Free delivery
            if special_offer.variables[:shipping]
              @cart.free_shipping = true
            end

         end
         retract product
        end
      end

    end
  end
end
