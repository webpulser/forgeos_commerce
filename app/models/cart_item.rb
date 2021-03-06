# Relation between <i>Cart</i> and <i>Product</i>
#
# ==== belongs_to
# * <tt>product</tt> - <i>Product</i>
# * <tt>cart</tt> - <i>Cart</i>

class CartItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart
  validates_presence_of :cart_id, :product_id

  def total
    return self.product.price({:voucher_discount => false})*quantity
  end

=begin
  def quantity
    return self.cart.cart_items.count('product_id', :conditions => {:product_id => self.product.id})
  end
=end

  # Returns total tax for this <i>Product</i>
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def tax(with_currency=true)
    ("%01.2f" % (total(true, with_currency) - total)).to_f
  end
end
