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
          if special_offer.variables[:discount]
            rate = special_offer.variables[:discount]
            new_price = special_offer.variables[:fixed_discount] ? product.price-rate : product.price-((product.price * rate) / 100)    
            product.update_attribute('new_price',new_price)
            
            if special_offer.variables[:fixed_discount]
              product.update_attribute('promo',"-#{rate}€")
            else
              product.update_attribute('promo',"-#{rate}%")
            end
          end
        
        ## Product in cart OR cart
        else
          # Discount product price --product_in_cart 
          if !special_offer.variables[:discount].nil?
            p "aha"*20
            rate = special_offer.variables[:discount]
            
            new_price = special_offer.variables[:fixed_discount] ? product.price-rate : product.price-((product.price * rate) / 100)    
            product.update_attributes!(:new_price => new_price)
            if special_offer.variables[:fixed_discount]
              product.update_attribute('promo',"-#{rate}€")
            else
              product.update_attribute('promo',"-#{rate}%")
            end
            p "new price : #{product.new_price}"
            p "save my attributes mother fucker !!!!!"
          end
                        
          # Free products  --cart and product_in_cart              
          special_offer.variables[:product_ids].each do |product_id|
            @free_product_ids << product_id
          end if special_offer.variables[:product_ids]
        
          # Discount cart total price  --cart
          #@cart.discount_cart(special_offer.variables[:cart_discount], special_offer.variables[:percent]) if special_offer.variables[:cart_discount]
        
       end
       retract product
      end
    end
  end
end
