# This model use ActsAsStateMachine
#
# ==== belongs_to
# * <tt>address_delivery</tt> - <i>AddressDelivery</i>
# * <tt>address_invoice</tt> - <i>AddressInvoice </i>
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>order_details</tt> - <i>OrdersDetail</i>
#
# ==== Attributes
# * <tt>transporter</tt> - <i>Transporter</i> name
# * <tt>transporter_price</tt> - <i>ShippingMethod</i> price
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

  has_many :order_details, :dependent => :destroy
  has_one :order_shipping, :dependent => :destroy
  accepts_nested_attributes_for :order_details, :allow_destroy => true
  accepts_nested_attributes_for :order_shipping

  has_one :address_delivery
  has_one :address_invoice
  accepts_nested_attributes_for :address_delivery
  accepts_nested_attributes_for :address_invoice

  belongs_to :user
  validates_presence_of :user_id, :address_delivery, :address_invoice, :order_shipping

  # Returns order's amount
  def total(with_tax=false, with_currency=true,with_shipping=true, with_vouchers=true )
    amount = 0
    order_details.each do |order_detail|
      amount += order_detail.total(with_tax, with_currency)
    end
    amount += order_shipping.price if with_shipping && order_shipping
    amount -= voucher.to_f if with_vouchers
    return ("%01.2f" % amount).to_f
  end

  #def total(with_tax=false, with_currency=true)
  #  order_details.inject(0) { |total, order_detail| total += order_detail.total(with_tax, with_currency) } + transporter_price - voucher.to_f
  #end

  def taxes
    ("%01.2f" % (total(true) - total)).to_f
  end

  def product_names
    count = self.order_details.count
    if count == 1
      return self.order_details.first.name
    else
      return "#{count} #{I18n.t('product', :count => 2)}"
    end
  end
end
