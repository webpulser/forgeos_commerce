# ==== belongs_to
# * <tt>order</tt> - <i>Order</i>
#
# ==== Attributes
# * <tt>name</tt> - <i>Product</i> name
# * <tt>description</tt> - <i>Product</i> description
# * <tt>price</tt> - <i>Product</i> price
# * <tt>rate_tax</tt> - <i>Product</i> rate_tax
# * <tt>quantity</tt> - <i>Product</i> quantity
class OrderDetail < ActiveRecord::Base

  belongs_to :order
  belongs_to :product

  #validates_presence_of :name, :price, :rate_tax, :order_id, :sku
  validates_presence_of :name, :price, :sku
  after_create :increment_product_sold_counter

  def rate_tax
    read_attribute(:rate_tax) || 1
  end
  # Returns price's string with currency symbol
  #
  # This method is an overload of <i>price</i> attribute.
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price(with_tax=false, with_currency=true,with_special_offer=false, with_voucher=false)
    return 0 unless read_attribute(:price)
    price = read_attribute(:price)
    price -= self.special_offer_discount_price if with_special_offer and self.special_offer_discount_price
    price -= self.voucher_discount_price if with_voucher and self.voucher_discount_price
    price += tax(false) if with_tax
    return price
  end

  # Returns total product's tax
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  #
  # This method use <i>price</i> : <i>price(false, with_currency)</i>
  def tax(with_currency=true)
    price(false, with_currency) * rate_tax/100.0
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
  def total(with_tax=false, with_currency=true,with_special_offer=false,with_voucher=false, order = self.order)
    price(with_tax, with_currency,with_special_offer,with_voucher) * quantity(order)
  end

  def quantity(order = self.order)
    return 1 unless order
    siblings = order.order_details.group_by(&:product_id).find do |order_detail_group|
      order_detail_group[1].first.product_id == product_id
    end
    return siblings ? siblings[1].size : 1
  end
private

  def increment_product_sold_counter
    if product
      counter = product.sold_counters.new.increment_counter
    end
  end
end
