require 'ruleby'
class Voucher < Ruleby::Rulebook
  
  attr_writer :code, :cart, :free_product_ids

  def rules
    VoucherRule.find_all_by_active_and_code(true,@code).each do |voucher|
      rule eval(voucher.conditions) do |context|
        @cart.voucher = voucher.id
         
        # NEED CODE
        
        # Voucher for a free product
        voucher.variables[:product_ids].each do |product_id|
          @free_product_ids << product_id
        end if voucher.variables[:product_ids]
        
        # Voucher for a product price discount
        
        # Voucher for a free shipping 
        if voucher.variables[:shipping]
          @cart.free_shipping = true
        end
         
        # Voucher for a cart total_amount discount
        if voucher.variables[:cart_discount]
          rate = voucher.variables[:cart_discount]
          discount_price = voucher.variables[:fixed_discount] ? rate : (@cart.total * rate) / 100         
          @cart.voucher_discount_price = discount_price
          voucher.variables[:fixed_discount]? @cart.voucher_discount = "-#{rate}€" : @cart.voucher_discount = "-#{rate}%"
        end
        p "cool"*10              
      end
    end
  end
end
