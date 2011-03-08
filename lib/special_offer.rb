require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart, :free_product_ids, :current_rules, :selected_products

  def rules
    #OPTIMIZE
    @current_rules ||= SpecialOfferRule.find_all_by_active(true)
    @current_rules.each do |special_offer|
      eval_rule(special_offer)
    end
  end

  def rule_preview(rule_preview)
    if rule_preview.is_a?(SpecialOfferRule)
      rule eval(rule_preview.conditions) do |context|
        product = context[:product]
        @selected_products << product.id
        retract product
      end
    end
  end

  def eval_rule(special_offer)
    rule eval(special_offer.conditions) do |context|
      product = context[:product]

      if @cart
        # Free products  --cart and product_in_cart
        special_offer.variables[:product_ids].each do |product_id|
          @free_product_ids << product_id
        end if special_offer.variables[:product_ids]

        # Discount cart total price  --cart
        if rate = special_offer.variables[:cart_discount]
          discount_price = special_offer.variables[:fixed_discount] ? rate : (@cart.total * rate) / 100
          @cart.special_offer_discount_price = discount_price
          special_offer.variables[:fixed_discount]? @cart.special_offer_discount = "-#{rate}" : @cart.special_offer_discount = "-#{rate}%"
        end

        # Free delivery
        @cart.free_shipping = true if special_offer.variables[:shipping]
      end

      # Product in Shop
      apply_discount_on_product(special_offer,product)
      @selected_products << product if @selected_products.kind_of?(Array) or @selected_products.kind_of?(Set)
      retract product if product
    end
  end

  def apply_discount_on_product(special_offer,product)
    return unless special_offer and product
    if rate = special_offer.variables[:discount]
      discount_price = special_offer.variables[:fixed_discount] ? rate : (product.price * rate) / 100
      product.special_offer_discount_price = discount_price
      special_offer.variables[:fixed_discount] ? product.special_offer_discount = "-#{rate}" : product.special_offer_discount = "-#{rate}%"
    end
  end
end
