# ==== belongs_to
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>carts_product</tt> - <i>CartsProduct</i>
# * <tt>products</tt> - <i>Product</i>
class Cart < ActiveRecord::Base

  has_many :carts_products, :dependent => :destroy
  has_many :products, :through => :carts_products
  has_and_belongs_to_many :free_shipping_method_details, :class_name => 'ShippingMethodDetail'

  belongs_to :user
  before_save :destroy_duplicates
  
  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  def add_product(product,free=false)
    return false if product.nil? || product.new_record?
    carts_products << CartsProduct.create(:product_id => product.id, :free => free)
  end

  def has_free_product?(product_id)
    return !carts_products.find_by_product_id_and_free(product_id,true).nil?
  end

  def add_new_price(carts_product_id, new_price)
    carts_products.find_by_id(carts_product_id).update_attributes!(:new_price => new_price)
  end
 
  def get_new_price(carts_product_id)
    return carts_products.find_by_id(carts_product_id).new_price
  end

  def destroy_duplicates
    Cart.destroy_all(:user_id => user_id) unless user_id.nil?
  end
  
  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product_id</tt> - an <i>id</i> of a <i>Product</i>
  # This method use <i>add_product</i>
  def add_product_id(product_id, free=false)
    add_product(Product.find_by_id(product_id))
  end

  # Remove a product of this cart
  def remove_product(carts_product_id)
    return false if carts_products.nil?
    # destroy the product
    cart_product = carts_products.find_by_product_id(carts_product_id)
    cart_product.each do |product|
      product.destroy if cart_product
    end
    # destroy free product
    free_products = carts_products.find_by_free(1)
    free_products.destroy if free_products
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
  def total(with_tax=false, product=nil, with_discount=false)
    if product.nil?
      total = CartsProduct.find_all_by_cart_id_and_free(id,false).inject(0) { |total, carts_product| total + carts_product.total(with_tax) }
      if with_discount and !self.discount.nil? 
        self.percent.nil? ? total-=self.discount : total-= (total*self.discount)/100
      end
      return total
    else
      CartsProduct.find_all_by_cart_id_and_product_id(id, product.id).inject(0) { |total, carts_product| total + carts_product.total(with_tax) }
    end
  end

  def total_with_tax
    total(true)
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

  # Returns all <i>ShippingMethodDetail</i> available for this cart
  def get_shipping_method_details
    shipping_method_details = []
    ShippingMethod.all.each do |shipping_method|
      shipping_method_details += shipping_method.shipping_method_details.find(:all, :conditions => { :weight_min_lte => weight, :weight_max_gte => weight})
      shipping_method_details += shipping_method.shipping_method_details.find(:all, :conditions => { :price_min_lte => total(true), :price_max_gte => total(true)})
    end
    shipping_method_details.uniq
  end
  
  def total_items
    return carts_products.length
  end
  
  def discount_cart(discount, percent=nil)
    percent.nil? ? self.update_attributes(:discount => discount) : self.update_attributes(:discount => discount, :percent => 1)
  end
  
end
