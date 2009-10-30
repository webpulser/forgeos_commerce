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

  define_index do
    indexes status, :sortable => true
    indexes order_details.name, :facet => true,  :sortable => true
    indexes order_details.description, :facet => true,  :sortable => true
    indexes order_details.sku, :facet => true,  :sortable => true
    indexes order_details.price, :facet => true,  :sortable => true
  end

  # Returns order's amount
  def total(with_tax=false, with_currency=true,with_shipping=true,with_special_offer=false, with_voucher=false)
    amount = 0
    order_details.each do |order_detail|
      price = order_detail.total(with_tax, with_currency,with_special_offer,with_voucher)
      amount += price if price
    end
    amount += order_shipping.price if with_shipping && order_shipping && order_shipping.price
    amount -= self.special_offer_discount if with_special_offer && self.special_offer_discount
    amount -= self.voucher_discount if with_voucher && self.voucher_discount
    return ("%01.2f" % amount).to_f
  end

  def taxes
    ("%01.2f" % (total(true) - total)).to_f
  end

  def total_items
    return order_details.length
  end

  def product_names
    count = self.order_details.count
    if count == 1
      return self.order_details.first.name
    else
      return "#{count} #{I18n.t('product', :count => 2)}"
    end
  end
  
  def weight
    weight=0
    self.order_details.each do |product| 
      weight+=product.product.weight
    end
    return weight
  end
  
  def special_offer_discount_products
    return order_details.all(:conditions => ['special_offer_discount_price IS NOT NULL'])
  end
  
  def voucher_discount_products
    return order_details.all(:conditions =>['voucher_discount_price IS NOT NULL'])
  end
end
