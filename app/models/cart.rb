# ==== belongs_to
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>cart_items</tt> - <i>CartItem</i>
# * <tt>products</tt> - <i>Product</i>
class Cart < ActiveRecord::Base
  attr_accessor :voucher_discount, :voucher_discount_price, :voucher
  attr_accessor :special_offer_discount, :special_offer_discount_price
  attr_accessor :free_shipping
  has_many :cart_items, :dependent => :destroy

  [:carts_products, :carts_products=, :carts_product_ids, :carts_products_ids].each do |method_sym|
    define_method method_sym do |*args|
      ActiveSupport::Deprecation.warn('use cart_items instead of carts_products')
      self.send("cart_item#{method_sym.to_s.gsub(/^carts_product/, '')}", args)
    end
  end

  has_many :products, :through => :cart_items
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
      cart_items << CartItem.create(:product_id => product_id)
    end
  end

  def remove_product(product,quantity=nil)
    remove_product_id(product.id,quantity)
  end

  def remove_product_id(product_id, quantity = 1)
    return false if self.cart_items.nil?
    cart_item = self.cart_items.find_all_by_product_id(product_id)
    cart_item.first(quantity).map(&:destroy)
  end


  # Empty this cart
  def to_empty
    cart_items.destroy_all
  end

  # Returns true if cart is empty, returns false else
  def is_empty?
    total_items == 0
  end

  def taxes
    #total(true) - total(false)
  end

  def discount
    self.total({:cart_voucher_discount => false, :cart_special_offer_discount => false, :product_voucher_discount => false})-self.total
  end

  def total(options = {})
      options = {:tax => true,
                 :cart_voucher_discount => true,
                 :cart_special_offer_discount => true,
                 :product_voucher_discount => true,
                 :product_special_offer_discount => true,
                 :patronage => true,
                 :cart_packaging => true,
                 :product_packaging=> true }.update(options.symbolize_keys)

      total = 0
      cart_items.each do |cart_product|
        total += cart_product.product.price({:tax => options[:tax], :voucher_discount => options[:product_voucher_discount], :special_offer_discount => options[:product_special_offer_discount], :packaging => options[:product_packaging] })
      end
      total -= self.voucher_discount_price.to_f || 0 if options[:cart_voucher_discount]
      total -= self.special_offer_discount_price.to_f || 0 if options[:cart_special_offer_discount]
      total -= self.patronage_discount.to_f || 0 if options[:patronage]
      total += self.packaging_price.to_f || 0 if options[:cart_packaging]
      total = 0 if total < 0
      return total
  end
  
  def packaging_price
     #TODO get carts options from config
    return 0
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
      return cart_items.inject(0) { |total, cart_item| total + cart_item.product.weight }
    else
      cart_item = cart_items.find_by_product_id(product.id)
      return product.weight unless cart_item.nil?
    end
    return 0
  end

  def total_items
    return cart_items.length
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

  def transporter_id
    return 0 unless options[:transporter_rule_id]
    options[:transporter_rule_id].to_i
  end
end
