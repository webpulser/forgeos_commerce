# This model use ActsAsStateMachine
#
# ==== belongs_to
# * <tt>address_delivery</tt> - <i>AddressDelivery</i>
# * <tt>address_invoice</tt> - <i>AddressInvoice </i>
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>orders_details</tt> - <i>OrdersDetail</i>
#
# ==== Attributes
# * <tt>shipping_method</tt> - <i>ShippingMethod</i> name
# * <tt>shipping_method_price</tt> - <i>ShippingMethod</i> price
class Order < ActiveRecord::Base

  acts_as_state_machine :initial => :unpaid, :column => 'status'
  state :unpaid
  state :paid
  state :accepted
  state :sended

  event :paid do
    transitions :from => :unpaid, :to => :paid
  end

  event :accepted do
    #transitions :from => :unpaid, :to => :accepted
    transitions :from => :paid, :to => :accepted
  end

  event :sended do
    transitions :from => :accepted, :to => :sended
  end

  has_many :orders_details, :dependent => :destroy

  belongs_to :address_delivery
  belongs_to :address_invoice
  belongs_to :user

  validates_presence_of :user_id, :address_invoice_id, :address_delivery_id, :shipping_method, :shipping_method_price

  # Returns order's amount
  def total(with_tax=false, with_currency=true)
    orders_details.inject(0) { |total, orders_detail| total += orders_detail.total(with_tax, with_currency) } + shipping_method_price - voucher.to_f
  end

  # Returns shipping_method_price
  #
  # This method is an overload of <i>shipping_method_price</i> attribute.
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def shipping_method_price(with_currency=true)
    return super if Currency::is_default? || !with_currency || super.nil?
    ("%01.2f" % (super * $currency.to_exchanges_rate(Currency::default).rate)).to_f
  end
end
