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
  include AASM
  aasm_column :status
  aasm_initial_state :unpaid
  aasm_state :unpaid
  aasm_state :paid
  aasm_state :shipped
  aasm_state :canceled
  aasm_state :closed

  aasm_event :pay do
    transitions :to => :paid, :from => :unpaid
  end

  aasm_event :start_shipping do
    transitions :to => :shipped, :from => :paid 
  end

  aasm_event :cancel do
    transitions :to => :canceled, :from => [:unpaid, :shipped, :paid]
  end

  aasm_event :close do
    transitions :to => :closed, :from => [:shipped, :canceled]
  end

  has_many :orders_details, :dependent => :destroy
  has_one :order_shipping, :dependent => :destroy
  accepts_nested_attributes_for :order_shipping

  belongs_to :address_delivery
  belongs_to :address_invoice
  belongs_to :user

  validates_presence_of :user_id, :address_invoice_id, :address_delivery_id

  # Returns order's amount
  def total(with_tax=false, with_currency=true,with_shipping=true, with_vouchers=true )
    amount = 0
    orders_details.each do |orders_detail|
      amount += orders_detail.total(with_tax, with_currency)
    end
    amount += order_shipping.price if with_shipping && order_shipping
    amount -= voucher.to_f if with_vouchers
    return amount
  end

  def taxes
    total(true) - total
  end

  def product_names
    count = self.orders_details.count
    if count == 1
      return self.orders_details.first.name
    else
      return "#{count} #{I18n.t('product', :count => 2)}"
    end
  end
end
