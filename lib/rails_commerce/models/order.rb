module RailsCommerce
  # This model use ActsAsStateMachine
  #
  # ==== belongs_to
  # * <tt>address_delivery</tt> - <i>RailsCommerce::AddressDelivery</i>
  # * <tt>address_invoice</tt> - <i>RailsCommerce::AddressInvoice </i>
  # * <tt>user</tt> - <i>RailsCommerce::User</i>
  #
  # ==== has_many
  # * <tt>orders_details</tt> - <i>RailsCommerce::OrdersDetail</i>
  #
  # ==== Attributes
  # * <tt>shipping_method</tt> - <i>RailsCommerce::ShippingMethod</i> name
  # * <tt>shipping_method_price</tt> - <i>RailsCommerce::ShippingMethod</i> price
  class Order < ActiveRecord::Base
    set_table_name "rails_commerce_orders"

    acts_as_state_machine :initial => :unpaid, :column => 'status'
    state :unpaid
    state :paid
    state :accepted
    state :sended

    event :paid do
      transitions :from => :unpaid, :to => :paid
    end

    event :accepted do
#      transitions :from => :unpaid, :to => :accepted
      transitions :from => :paid, :to => :accepted
    end

    event :sended do
      transitions :from => :accepted, :to => :sended
    end

    has_many :orders_details, :class_name => 'RailsCommerce::OrdersDetail', :dependent => :destroy

    belongs_to :address_delivery, :class_name => 'RailsCommerce::AddressDelivery'
    belongs_to :address_invoice, :class_name => 'RailsCommerce::AddressInvoice'
    belongs_to :user, :class_name => 'RailsCommerce::User'

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
      return super if Currency::is_default? || !with_currency
      ("%01.2f" % (super * $currency.to_exchanges_rate(Currency::default).rate)).to_f
    end
  end
end
