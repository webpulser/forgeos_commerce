require 'ruleby'
class Voucher < Ruleby::Rulebook

  attr_writer :code, :cart, :free_product_ids

  def rules
    VoucherRule.find_all_by_active_and_code(true,@code).each do |voucher|
      rule eval(voucher.conditions) do |context|
        @cart.voucher = voucher.id

        # Voucher for a free product
        voucher.variables[:product_ids].each do |product_id|
          @free_product_ids << product_id
        end if voucher.variables[:product_ids]

        # Voucher for a product price discount
        if voucher.variables[:discount] and product = (context[:product] || context[:pack])
          rate = voucher.variables[:discount]
          options = {:voucher_discount => false}
          discount_price = voucher.variables[:fixed_discount] ? rate : (product.price(options) * rate).to_f / 100
          product.voucher_discount_price = discount_price
          product.voucher_discount = (voucher.variables[:fixed_discount] ? "-#{rate}" : "-#{rate}%")
        end

        # Voucher for a free shipping
        if voucher.variables[:shipping]
          @cart.free_shipping = true
        end

        # Voucher for a cart total_amount discount
        if voucher.variables[:cart_discount]
          rate = voucher.variables[:cart_discount]
          discount_price = voucher.variables[:fixed_discount] ? rate : (@cart.total({:cart_voucher_discount => false, :product_voucher_discount => false}) * rate).to_f / 100
          @cart.voucher_discount_price = discount_price
          @cart.voucher_discount = (voucher.variables[:fixed_discount] ? "-#{rate}" :  "-#{rate}%")
        end
      end
    end
  end
end
