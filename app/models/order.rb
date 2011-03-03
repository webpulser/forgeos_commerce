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
  aasm_state :paid, :after_enter => :payment_confirmation
  aasm_state :shipped, :after_enter => :enter_shipping_event
  aasm_state :canceled, :after_enter => :update_patronage
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

  has_one :address_delivery, :dependent => :destroy
  has_one :address_invoice, :dependent => :destroy
  accepts_nested_attributes_for :address_delivery
  accepts_nested_attributes_for :address_invoice

  belongs_to :user
  validates_presence_of :user_id
  validates_associated :address_delivery, :address_invoice, :order_shipping

  define_index do
    indexes status, :sortable => true
    indexes order_details.name, :facet => true,  :sortable => true
    indexes order_details.description, :facet => true,  :sortable => true
    indexes order_details.sku, :facet => true,  :sortable => true
    indexes order_details.price, :facet => true,  :sortable => true
  end

  before_save :update_patronage

  def aasm_current_state_with_event_firing=(state)
    aasm_events_for_current_state.each do |event_name|
      event = self.class.aasm_events[event_name]
      aasm_fire_event(event_name,false) if event && event.all_transitions.any?{ |t| t.to == state || t.to == state.to_sym }
    end
  end

  alias_method :aasm_current_state_with_event_firing, :aasm_current_state


  # Returns order's amount
  def total(with_tax=false, with_currency=true,with_shipping=true,with_special_offer=true, with_voucher=true, with_patronage=true)
    amount = 0
    order_details.each do |order_detail|
      price = order_detail.price(with_tax, with_currency,with_special_offer,with_voucher)
      amount += price if price
    end
    amount += order_shipping.price if with_shipping && order_shipping && order_shipping.price
    amount -= self.special_offer_discount if with_special_offer && self.special_offer_discount
    amount -= self.voucher_discount if with_voucher && self.voucher_discount
    amount -= self.patronage_discount if with_patronage
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

  def patronage_discount
    return read_attribute(:patronage_discount_price) if self.patronage_discount_price
    return 0 unless self.user
    if self.user.has_nephew_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(false,false,true,false,false,false) / 100
      else
        self.user.patronage_discount
      end
    elsif self.user.has_godfather_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(false,false,true,false,false,false) / 100
      else
        self.user.patronage_discount
      end
    else
      0
    end
  end

  def self.from_cart(cart)
    if cart and cart.user_id
      order_details_attributes = cart.carts_products.collect do |cart_product|
        OrderDetail.from_cart_product(cart_product).attributes
      end + Product.find_all_by_id(cart.options[:free_product_ids]).collect do |product|
        OrderDetail.from_free_product(product).attributes
      end

      order = self.new
      order.attributes = {
        :user_id => cart.user_id,
        :voucher_discount => cart.voucher_discount_price,
        :special_offer_discount => cart.special_offer_discount_price,
        :order_details_attributes => order_details_attributes,
        :reference => cart.id
      }

      order.build_order_shipping(OrderShipping.from_cart(cart).attributes)
      order.build_address_delivery(cart.address_delivery.attributes.update(:person_id => nil))
      order.build_address_invoice(cart.address_invoice.attributes.update(:person_id => nil))

      self.after_from_cart(order,cart) if self.respond_to?(:after_from_cart)
      return order
    end
  end

  private

  def payment_confirmation
    if self.user
      #Notifier.deliver_order_confirmation(self.user,self)
      # decrement user's patronage_count if its use has patronage
      User.decrement_counter(:patronage_count,self.user.id) if self.user.has_godfather_discount?
      # increment user's godfather patronage_count if its user's first order
      User.increment_counter(:patronage_count,self.user.godfather_id) if self.user.godfather and self.user.orders.count(:conditions => { :status => 'paid' }) == 1
    end
  end

  def enter_shipping_event
    #TODO write a generic function for this event
    #Override this function to do what you want
  end

  def update_patronage
    return true unless self.user and self.user.has_patronage_discount?
    case aasm_current_state
    when :unpaid
      # FIXME
      #User.decrement_counter(:patronage_count,self.user.godfather_id)
      self.patronage_discount_price = patronage_discount
    when :canceled
      User.increment_counter(:patronage_count,self.user.godfather_id)
    end
  end
end
