module RailsCommerce
  # ==== belongs_to
  # * <tt>order</tt> - <i>RailsCommerce::Order</i>
  #
  # ==== Attributes
  # * <tt>name</tt> - <i>RailsCommerce::Product</i> name
  # * <tt>description</tt> - <i>RailsCommerce::Product</i> description
  # * <tt>price</tt> - <i>RailsCommerce::Product</i> price
  # * <tt>rate_tax</tt> - <i>RailsCommerce::Product</i> rate_tax
  # * <tt>quantity</tt> - <i>RailsCommerce::Product</i> quantity
  class OrdersDetail < ActiveRecord::Base
    set_table_name "rails_commerce_orders_details"
    
    belongs_to :order, :class_name => 'RailsCommerce::Order'

    validates_presence_of :name, :description, :price, :rate_tax, :order_id, :quantity

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
      tax(with_currency) * quantity
    end

    # Returns price * quantity
    #
    # ==== Parameters
    # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
    # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
    def total(with_tax=false, with_currency=true)
      price(with_tax, with_currency) * quantity
    end
  end
end