require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart
  def rules
    SpecialOfferRule.find_all_by_activated(true).each do |special_offer|
      puts special_offer.conditions
      rule eval(special_offer.conditions) do |context|
        product = context[:product]
                
        ## Product in Shop
        if @cart.nil?
          p 'ahhhah ah '*10
          # Discount product price
                                                #and special_offer.variables[:for] == 'product_in_shop'
          if special_offer.variables[:discount]
             rate = special_offer.variables[:discount]
             product.price-= special_offer.variables[:fixed_discount] ? rate : ((product.price * rate) / 100)
             
             if special_offer.variables[:fixed_discount]
               product.barcode = "-#{rate}€"
             else
               product.barcode = "-#{rate}%"
             end
          end
        
        ## Product in cart OR cart
        else
          # Discount product price --product_in_cart 
          if !special_offer.variables[:discount].nil?
            rate = special_offer.variables[:discount]
            
            # product.barcode is the carts_product_id in the cart of the product 
            price = @cart.get_new_price(product.barcode.to_i)          
            
            new_price = price - (special_offer.variables[:fixed_discount] ? rate : ((price * rate) / 100))
            @cart.add_new_price(product.barcode.to_i, new_price)

          end
        
          #return true unless @cart
        
          # Free shippment --cart and product_in_cart
          @cart.free_shipping_method_detail_ids += special_offer.variables[:shipping_ids] if special_offer.variables[:shipping_ids]
        
          # Free products  --cart and product_in_cart
          special_offer.variables[:product_ids].each do |product_id|
            @cart.add_product(Product.find(product_id),true) unless @cart.has_free_product?(product_id)
          end if special_offer.variables[:product_ids]
        
          # Discount cart total price  --cart
          @cart.discount_cart(special_offer.variables[:cart_discount], special_offer.variables[:percent]) if special_offer.variables[:cart_discount]
        
       end
       #retract product
      end
    end
  end
end
