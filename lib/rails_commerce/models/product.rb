module RailsCommerce
  # A <i>RailsCommerce::Product</i> is an abstract class and can't be instanciable, use <i>RailsCommerce::ProductParent</i> or <i>RailsCommerce::ProductDetail</i>.
  # find's methods is already accepted
  #
  # ==== Subclasses
  # * <tt>RailsCommerce::ProductParent</tt>
  # * <tt>RailsCommerce::ProductDetail</tt>
  class Product < ActiveRecord::Base
    set_table_name "rails_commerce_products"

    # A <i>RailsCommerce::Product</i> is not instanciable, use <i>RailsCommerce::ProductParent</i> or <i>RailsCommerce::ProductDetail</i>.
    # find's methods is already accepted
    attr_accessor :is_instanciable

#    translates :name, :text

    has_many :carts_products, :class_name => 'RailsCommerce::CartsProduct', :dependent => :destroy
    has_many :carts, :class_name => 'RailsCommerce::Cart', :through => :carts_products

    has_and_belongs_to_many :categories, :join_table => 'rails_commerce_categories_products', :class_name => 'RailsCommerce::Category', :readonly => true
    has_many :sortable_pictures, :class_name => 'RailsCommerce::SortablePicture', :dependent => :destroy, :order => 'position'
    has_many :pictures, :through => :sortable_pictures, :class_name => 'RailsCommerce::Picture', :readonly => true, :order => 'rails_commerce_sortable_pictures.position'

    # Constructor's overload.
    #
    # <i>RailsCommerce::Product</i> is not instanciable, use <i>RailsCommerce::ProductParent</i> or <i>RailsCommerce::ProductDetail</i>.
    #
    # <i>RailsCommerce::Product.new</i> raise <i>RailsCommerce::Exception</i> code 101
    def initialize(options={})
      raise RailsCommerceException.new(:code => 101) if self.is_instanciable.nil? || !self.is_instanciable
      super(options)
    end

    # Overload the description attribute.
    #
    # Returns a empty string if <i>description</i> is <i>nil</i>
    def description
      (super.nil?) ? "" : super
    end

    # Returns product's price without tax by default
    #
    # The currency of user is considered by default
    #
    # ==== Parameters
    # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
    # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
    def price(with_tax=false, with_currency=true)
      price = super
      price += tax(false) if with_tax
      return price if Currency::is_default? || !with_currency
      ("%01.2f" % (price * $currency.to_exchanges_rate(Currency::default).rate)).to_f
    end

    # Returns price's string with currency symbol
    #
    # This method is an overload of <i>price</i> attribute.
    #
    # ==== Parameters
    # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
    # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
    def price_to_s(with_tax=false, with_currency=true)
      "#{price(with_tax, with_currency)} #{$currency.html}"
    end

    # Returns total product's tax
    #
    # ==== Parameters
    # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
    #
    # This method use <i>price</i> : <i>price(false, with_currency)</i>
    def tax(with_currency=true)
      return ("%01.2f" % (price(false, with_currency) * rate_tax/100)).to_f
    end
  end
end
