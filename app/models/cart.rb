# ==== belongs_to
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>carts_product</tt> - <i>CartsProduct</i>
# * <tt>products</tt> - <i>Product</i>
class Cart < ActiveRecord::Base
  attr_accessor :voucher_discount, :voucher_discount_price, :voucher
  attr_accessor :special_offer_discount, :special_offer_discount_price
  attr_accessor :free_shipping
  has_many :carts_products, :dependent => :destroy
  has_many :products, :through => :carts_products
  serialize :options

  belongs_to :user

  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  def add_product(product,quantity=nil)
    return false if product.nil? || product.new_record?
    add_product_id(product.id,quantity)
  end

  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product_id</tt> - an <i>id</i> of a <i>Product</i>
  # This method use <i>add_product</i>
  def add_product_id(product_id,quantity=1)
    quantity.times do
      carts_products << CartsProduct.create(:product_id => product_id)
    end
  end

  def remove_product(product,quantity=nil)
    remove_product_id(product.id,quantity)
  end

  def remove_product_id(product_id, quantity = 1)
    return false if self.carts_products.nil?
    cart_product = self.carts_products.find_all_by_product_id(product_id)
    cart_product.first(quantity).map(&:destroy)
  end


  # Empty this cart
  def to_empty
    carts_products.destroy_all
  end

  # Returns true if cart is empty, returns false else
  def is_empty?
    total_items == 0
  end

  def taxes
    total(true) - total(false)
  end

  def total(with_tax = false, with_discount = true)
    total = 0
    carts_products.each do |cart_product|
      product_price = cart_product.product.price(with_tax)
      if with_discount
        product_price -= cart_product.product.special_offer_discount_price if cart_product.product.special_offer_discount_price
        product_price -= cart_product.product.voucher_discount_price if cart_product.product.voucher_discount_price
      end
      #total += cart_product.product.new_price.nil? ? cart_product.product.price : cart_product.product.new_price
      total += product_price
    end

    if with_discount
      # discount total price if there are a special offer
      total -= self.special_offer_discount_price if self.special_offer_discount_price
      # discount total price if there are a valid voucher
      total -= self.voucher_discount_price if self.voucher_discount_price

      total -= self.patronage_discount
    end
    total = 0 if total < 0
    return total
  end

  def patronage_discount
    return 0 unless self.user
    if self.user.has_nephew_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(false,false) / 100
      else
        self.user.patronage_discount
      end
    elsif self.user.has_godfather_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(false,false) / 100
      else
        self.user.patronage_discount
      end
    else
      0
    end
  end

  # Returns weight of this cart
  def weight(product=nil)
    if product.nil?
      return carts_products.inject(0) { |total, carts_product| total + carts_product.product.weight }
    else
      carts_product = carts_products.find_by_product_id(product.id)
      return product.weight unless carts_product.nil?
    end
    return 0
  end

  def total_items
    return carts_products.length
  end

  def discount_cart(discount, percent=nil)
    percent.nil? ? self.update_attributes(:discount => discount) : self.update_attributes(:discount => discount, :percent => 1)
  end

  def address_invoice
    AddressInvoice.find_by_id(options[:address_invoice_id])
  end

  def address_delivery
    AddressDelivery.find_by_id(options[:address_delivery_id])
  end

  def transporter
    TransporterRule.find_by_id(options[:transporter_rule_id])
  end

  def options
    self.options = Hash.new unless super
    super
  end
end
