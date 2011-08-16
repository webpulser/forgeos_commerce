class OrderDetail < ActiveRecord::Base

  belongs_to :order
  belongs_to :product

  #validates_presence_of :name, :price, :rate_tax, :order_id, :sku
  validates :name, :price, :sku, :presence => true

  def rate_tax
    value = read_attribute(:rate_tax)
    (not value or value < 1.0) ? 1.0 : value
  end

  # Returns price's string with currency symbol
  #
  # This method is an overload of <i>price</i> attribute.
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price(*args)
    passed_options = args.extract_options!
    options = {
      :tax => true,
      :voucher_discount => true,
      :special_offer_discount => true,
      :packaging => false,
    }.update(passed_options.symbolize_keys)

    price = read_attribute(:price) || 0.0
    price *= rate_tax if options[:tax]
    price -= self.special_offer_discount_price || 0.0 if options[:special_offer_discount]
    price -= self.voucher_discount_price || 0.0 if options[:voucher_discount]
    price += self.packaging_price.to_f || 0.0 if options[:packaging]
    price
  end

  def discount(*args)
    passed_options = args.extract_options!
    options = {
      :voucher_discount => true,
      :special_offer_discount => true,
    }.update(passed_options.symbolize_keys)

    discount = 0.0
    discount += self.special_offer_discount_price.to_f || 0.0 if options[:special_offer_discount]
    discount += self.voucher_discount_price.to_f || 0.0 if options[:voucher_discount]
    discount
  end

  def old_price(with_tax=false, with_currency=true, with_special_offer=false, with_voucher=false)
    ActiveSupport::Deprecation.warn('use price instead of old_price')
    price({
      :tax => with_tax,
      :special_offer_discount => with_special_offer,
      :voucher_discount => with_voucher,
    })
  end

  # Returns total product's tax
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  #
  # This method use <i>price</i> : <i>price(false, with_currency)</i>
  def tax(with_currency=true)
    price(:tax => true, :with_currency => with_currency) / rate_tax
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
  def total
    price.to_f * quantity.to_f
  end

  def self.from_cart_product(cart_product)
    object = self.new(
      :name => cart_product.product.name,
      :description => cart_product.product.description,
      :price => cart_product.product.price(
          :voucher_discount => false,
          :special_offer_discount => false
      ),
      :rate_tax => cart_product.product.rate_tax,
      :sku => cart_product.product.sku,
      :product_id => cart_product.product.id,
      :voucher_discount => cart_product.product.voucher_discount,
      :voucher_discount_price => cart_product.product.voucher_discount_price,
      :special_offer_discount => cart_product.product.special_offer_discount,
      :special_offer_discount_price => cart_product.product.special_offer_discount_price,
      :quantity => cart_product.quantity
    )
    self.after_from_cart_product(object,cart_product) if self.respond_to?(:after_from_cart_product)
    return object
  end

  def self.from_free_product(gift)
    self.new(
      :name => gift.name,
      :description => gift.description,
      :price => 0,
      :rate_tax => 0,
      :sku => gift.sku,
      :product_id => gift.id,
      :special_offer_discount => I18n.t(:free_product),
      :special_offer_discount_price => 0
    )
  end


  def increment_product_sold_counter
    if product
      quantity.times do
        product.sold_counters.new.increment_counter
      end
    end
  end
end
