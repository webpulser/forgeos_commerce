# ==== belongs_to
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>carts_product</tt> - <i>CartsProduct</i>
# * <tt>products</tt> - <i>Product</i>
class Cart < ActiveRecord::Base

  has_many :carts_products, :dependent => :destroy
  has_many :products, :through => :carts_products
  belongs_to :user
  before_save :destroy_duplicates
  # Add a <i>product</i> in this cart
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:quantity</tt> - the quantity (1 by default)
  # If this product is already in this cart, the quantity is <b>add</b> with the actual quantity
  def add_product(product, quantity=1)
    return false if product.nil? || product.is_a?(ProductParent) || product.new_record?

    # if cart include product : add quantity
    # else add product with set_quantity
    unless products.include? product
      carts_products << CartsProduct.create(:product_id => product.id, :quantity => quantity)
    else
      set_quantity(product, size(product) + quantity)
    end
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
  # * <tt>:quantity</tt> - the quantity (1 by default)
  # This method use <i>add_product</i>
  def add_product_id(product_id, quantity=1)
    add_product(Product.find_by_id(product_id), quantity)
  end

  # Remove a product of this cart
  #
  # Returns false if <i>product</i> is <i>nil</i>
  #
  # ==== Parameters
  #
  # * <tt>:product</tt> - a <i>Product</i> object
  def remove_product(product)
    return false if product.nil?
    carts_products.find_by_product_id(product.id).destroy
    carts_products.reject! { |carts_product| carts_product.product_id == product.id }
  end

  # Remove a product of this cart
  #
  # Returns false if <i>product</i> is <i>nil</i>
  #
  # ==== Parameters
  # * <tt>:product_id</tt> - an <i>id</i> of a <i>Product</i>
  # This method use <i>remove_product</i>
  def remove_product_id(product_id)
    remove_product(Product.find_by_id(product_id))
  end

  # Update quantity of a <i>Product</i>
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:quantity</tt> - the new quantity
  def set_quantity(product, quantity)
    quantity = quantity.to_i
    carts_products.each do |carts_product|
       if carts_product.product_id == product.id
         return remove_product(product) if quantity == 0
         carts_product.update_attribute(:quantity, quantity)
       end
     end
  end

  # Returns the total quantity of this cart by default
  #
  # Returns the product's quantity if you precise a <i>Product</i> object in parameters
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  def size(product=nil)
    if product.nil?
      return carts_products.inject(0) { |total, carts_product| total + carts_product.quantity }
    else
      carts_product = carts_products.find_by_product_id(product.id)
      return carts_product.quantity unless carts_product.nil?
    end
    return 0
  end

  # Returns product's count of this cart
  def count_products
    products.size
  end

  # Empty this cart
  def to_empty
    carts_products.destroy_all
  end

  # Returns true if cart is empty, returns false else
  def is_empty?
    count_products == 0
  end

  # Returns total price of this cart by default
  #
  # Returns total price of a <i>Product</i> in cart if you precise in parameters
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - add tax of price if true, false by default
  # * <tt>:product</tt> - a <i>Product</i> object
  def total(with_tax=false, product=nil)
    if product.nil?
      CartsProduct.find_all_by_cart_id(id).inject(0) { |total, carts_product| total + carts_product.total(with_tax) }
    else
      CartsProduct.find_all_by_cart_id_and_product_id(id, product.id).inject(0) { |total, carts_product| total + carts_product.total(with_tax) }
    end
  end

  # Returns weight of this cart
  def weight
    products.inject(0) { |total, product| total + product.weight }
  end

  # Returns all <i>ShippingMethodDetail</i> available for this cart
  def get_shipping_method_details
    shipping_method_details = []
    ShippingMethod.find(:all).each do |shipping_method|
      shipping_method_details += shipping_method.shipping_method_details.find(:all, :conditions => ["weight_min <= ? AND weight_max >= ?", weight, weight])
    end
    shipping_method_details
  end
end
