require 'ruleby'
class SpecialOffer < Ruleby::Rulebook
  attr_writer :cart, :free_product_ids
  def rules
    SpecialOfferRule.find_all_by_active(true).each do |special_offer|
      #puts special_offer.conditions
      rule eval(special_offer.conditions) do |context|
        product = context[:product]
        p "hu"*30
        p product.inspect        
        ## Product in Shop
        if @cart.nil?
          #p 'ahhhah ah '*10
          # Discount product price
                                                #and special_offer.variables[:for] == 'product_in_shop'
          #if special_offer.variables[:discount]
          #  rate = special_offer.variables[:discount]
          #  new_price = special_offer.variables[:fixed_discount] ? product.price-rate : product.price-((product.price * rate) / 100)    
          #  product.update_attribute('new_price',new_price)
          #  
          #  if special_offer.variables[:fixed_discount]
          #    product.update_attribute('promo',"-#{rate}€")
          #  else
          #    product.update_attribute('promo',"-#{rate}%")
          #  end
          #end
          if special_offer.variables[:discount]
            rate = special_offer.variables[:discount]
            discount_price = special_offer.variables[:fixed_discount] ? rate : (product.price * rate) / 100
            product.special_offer_discount_price = discount_price
            special_offer.variables[:fixed_discount] ? product.special_offer_discount = "-#{rate}€" : product.special_offer_discount = "-#{rate}%"
          end
        
        
        
        ## Product in cart OR cart
        else
          
          ## FIXME - need to works with vouchers
          # Discount product price --product_in_cart 
          #if !special_offer.variables[:discount].nil?
          #  rate = special_offer.variables[:discount]
          #  
          #  new_price = special_offer.variables[:fixed_discount] ? product.price-rate : product.price-((product.price * rate) / 100)    
          #  product.update_attributes!(:new_price => new_price)
          #  if special_offer.variables[:fixed_discount]
          #    product.update_attribute('promo',"-#{rate}€")
          #  else
          #    product.update_attribute('promo',"-#{rate}%")
          #  end
          #end
           
          if special_offer.variables[:discount]
            rate = special_offer.variables[:discount]
            discount_price = special_offer.variables[:fixed_discount] ? rate : (product.price * rate) / 100
            product.special_offer_discount_price = discount_price
            special_offer.variables[:fixed_discount] ? product.special_offer_discount = "-#{rate}€" : product.special_offer_discount = "-#{rate}%"
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
            special_offer.variables[:fixed_discount]? @cart.special_offer_discount = "-#{rate}€" : @cart.special_offer_discount = "-#{rate}%"
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
