# ==== belongs_to
# * <tt>order</tt> - <i>Order</i>
#
# ==== Attributes
# * <tt>name</tt> - <i>Product</i> name
# * <tt>description</tt> - <i>Product</i> description
# * <tt>price</tt> - <i>Product</i> price
# * <tt>rate_tax</tt> - <i>Product</i> rate_tax
# * <tt>quantity</tt> - <i>Product</i> quantity
class OrdersDetail < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :product

  validates_presence_of :name, :price, :rate_tax, :order_id, :sku
  after_create :increment_product_sold_counter

  # Returns price's string with currency symbol
  #
  # This method is an overload of <i>price</i> attribute.
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price(with_tax=false, with_currency=true)
    return nil if super.nil? # assert
    price = super
    price += tax(false) if with_tax
    return ("%01.2f" % price).to_f if Currency::is_default? || !with_currency
    ("%01.2f" % (price * $currency.to_exchanges_rate(Currency::default).rate)).to_f
  end

  # Returns total product's tax
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  #
  # This method use <i>price</i> : <i>price(false, with_currency)</i>
  def tax(with_currency=true)
    ("%01.2f" % (price(false, with_currency) * rate_tax/100)).to_f
  end

  # Returns tax * quantity
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def total_tax(with_currency=true)
    tax(with_currency)
  end

  # Returns price * quantity
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def total(with_tax=false, with_currency=true)
    price(with_tax, with_currency)
  end
private
  
  def increment_product_sold_counter
    counter = product.product_sold_counters.new
    unless counter.increment_counter
      counter.save
    end
  end
end
