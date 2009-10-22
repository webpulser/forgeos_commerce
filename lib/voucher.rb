require 'ruleby'
class Voucher < Ruleby::Rulebook
  
  attr_writer :code, :cart

  def rules
    VoucherRule.find_all_by_active_and_code(true,@code).each do |voucher|
      rule eval(voucher.conditions) do |context|
         @cart.voucher = voucher.id
         
         # NEED CODE
         
         # Voucher for a cart total_amount discount
         if voucher.variables[:cart_discount]
           rate = voucher.variables[:cart_discount]
           discount_price = voucher.variables[:fixed_discount] ? rate : (@cart.total * rate) / 100         
           @cart.voucher_discount_price = discount_price
           voucher.variables[:fixed_discount]? @cart.voucher_discount = "-#{rate}€" : @cart.voucher_discount = "-#{rate}%"
         end
                       
      end
    end
  end
end
