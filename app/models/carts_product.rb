# Relation between <i>Cart</i> and <i>Product</i>
#
# ==== belongs_to
# * <tt>product</tt> - <i>Product</i>
# * <tt>cart</tt> - <i>Cart</i>

class CartsProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart
  validates_presence_of :cart_id, :product_id

  # Return total price of this <i>Product</i>
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by default, returns total price <b>with tax</b> if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  #def total(with_tax=false, with_currency=true)
  #  if new_price.nil?
  #    return ("%01.2f" % (product.price(with_tax, with_currency))).to_f
  #  else
  #    return ("%01.2f" % (with_tax ? (new_price + (new_price * product.rate_tax / 100)) : new_price )).to_f
  #  end 
  #end
  
  def total
    product_price = product.price
    product_price -= product.special_offer_discount_price if product.special_offer_discount_price
    product_price -= product.voucher_discount_price if product.voucher_discount_price
    return product_price  
  end


  # Returns total tax for this <i>Product</i>
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def tax(with_currency=true)
    ("%01.2f" % (total(true, with_currency) - total)).to_f
  end
  
  def quantity
    return self.cart.carts_products.count('product_id', :conditions => {:product_id => self.product.id})
  end
  
end
