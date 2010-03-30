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
  
  belongs_to :user
  
  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  def add_product(product)
    return false if product.nil? || product.new_record?
    carts_products << CartsProduct.create(:product_id => product.id)
  end

  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product_id</tt> - an <i>id</i> of a <i>Product</i>
  # This method use <i>add_product</i>
  def add_product_id(product_id)
    add_product(Product.find_by_id(product_id))
  end

  # Remove a product of this cart
  def remove_product(product_id)
    return false if carts_products.nil?
    # destroy the product
    cart_product = carts_products.find_all_by_product_id(product_id)
    cart_product.each do |product|
      product.destroy
    end
  end

  # Empty this cart
  def to_empty
    carts_products.destroy_all
  end

  # Returns true if cart is empty, returns false else
  def is_empty?
    total_items == 0
  end

  # Returns total price of this cart by default
  #
  # Returns total price of a <i>Product</i> in cart if you precise in parameters
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - add tax of price if true, false by default
  # * <tt>:product</tt> - a <i>Product</i> object
  def total_old(with_tax=false, product=nil, with_discount=false)
    if product.nil?
      total = CartsProduct.find_all_by_cart_id(id).inject(0) { |total, carts_product| total + carts_product.total(with_tax) }
      if with_discount and !self.discount.nil? 
        self.percent.nil? ? total-=self.discount : total-= (total*self.discount)/100
      end
      return total
    else
      CartsProduct.find_all_by_cart_id_and_product_id(id, product.id).inject(0) { |total, carts_product| total + carts_product.total(with_tax) }
    end
  end

  def total
    total = 0
    carts_products.each do |cart_product|
      product_price = cart_product.product.price
      product_price -= cart_product.product.special_offer_discount_price if cart_product.product.special_offer_discount_price
      product_price -= cart_product.product.voucher_discount_price if cart_product.product.voucher_discount_price
      total += product_price
      #total += cart_product.product.new_price.nil? ? cart_product.product.price : cart_product.product.new_price
    end
    
    # discount total price if there are a special offer
    total -= self.special_offer_discount_price if self.special_offer_discount_price
    # discount total price if there are a valid voucher
    total -= self.voucher_discount_price if self.voucher_discount_price
    total = 0 if total < 0 
    return total
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
  
end
