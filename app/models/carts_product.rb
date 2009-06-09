# Relation between <i>Cart</i> and <i>Product</i>
#
# ==== belongs_to
# * <tt>product</tt> - <i>Product</i>
# * <tt>cart</tt> - <i>Cart</i>
#
# ==== attributes
# * <tt>quantity</tt>
class CartsProduct < ActiveRecord::Base
  
  belongs_to :product
  belongs_to :cart
  validates_presence_of :cart_id, :product_id, :quantity

  # Return total price of this <i>Product</i>
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by default, returns total price <b>with tax</b> if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def total(with_tax=false, with_currency=true)
    ("%01.2f" % (product.price(with_tax, with_currency) * quantity)).to_f
  end

  # Returns total tax for this <i>Product</i>
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def tax(with_currency=true)
    ("%01.2f" % (total(true, with_currency) - total)).to_f
  end
end
