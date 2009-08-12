require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart
  def rules
    SpecialOfferRule.find_all_by_activated(true).each do |special_offer|
      puts special_offer.conditions
      rule eval(special_offer.conditions) do |context|
        
        puts "test"*20
        product = context[:product]
        
        
        ## Product in Shop
        if @cart.nil?
          # Discount product price
          if special_offer.variables[:fixed_discount] and special_offer.variables[:for] == 'product_in_shop'
             rate = special_offer.variables[:discount]
             product.price-= special_offer.variables[:fixed_discount] ? rate : ((product.price * rate) / 100)
          end
        
        ## Product in cart
        else
          # Discount product price
          if special_offer.variables[:fixed_discount]
            rate = special_offer.variables[:discount]
            
            # product.barcode is the carts_product_id in the cart of the product 
            price = @cart.get_new_price(product.barcode.to_i)          
            
            new_price = price - (special_offer.variables[:fixed_discount] ? rate : ((price * rate) / 100))
            @cart.add_new_price(product.barcode.to_i, new_price)

          end
        
          return true unless @cart
        
          # Free shippment
          @cart.free_shipping_method_detail_ids += special_offer.variables[:shipping_ids] if special_offer.variables[:shipping_ids]
        
          # Free products
          special_offer.variables[:product_ids].each do |product_id|
            @cart.add_product(Product.find(product_id),true) unless @cart.has_free_product?(product_id)
          end if special_offer.variables[:product_ids]
        
       end
       #retract product
      end
    end
  end
end
