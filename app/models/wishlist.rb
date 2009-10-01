# ==== belongs_to
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>products_wishlist</tt> - <i>ProductsWishlist</i>
# * <tt>products</tt> - <i>Product</i>
class Wishlist < ActiveRecord::Base

  has_many :products_wishlists, :dependent => :destroy
  has_many :products, :through => :products_wishlists
  belongs_to :user

  # Add a <i>product</i> in this wishlist
  #
  # Returns false if <i>product</i> is <i>nil</i> or not recorded
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  # * <tt>:quantity</tt> - the quantity (1 by default)
  # If this product is already in this wishlist, the quantity is <b>add</b> with the actual quantity
  def add_product(product, quantity=1)
    return false if product.nil? || product.new_record?

    # if wishlist include product : add quantity
    # else add product with set_quantity
    unless products.include? product
      products_wishlists << ProductsWishlist.create(:product_id => product.id, :quantity => quantity)
    else
      set_quantity(product, size(product) + quantity)
    end
  end

  # Add a <i>product</i> in this wishlist
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

  # Remove a product of this wishlist
  #
  # Returns false if <i>product</i> is <i>nil</i>
  #
  # ==== Parameters
  #
  # * <tt>:product</tt> - a <i>Product</i> object
  def remove_product(product)
    return false if product.nil?
    products_wishlists.find_by_product_id(product.id).destroy
    products_wishlists.reject! { |products_wishlist| products_wishlist.product_id == product.id }
  end

  # Remove a product of this wishlist
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
    products_wishlists.each do |products_wishlist|
       if products_wishlist.product_id == product.id
         return remove_product(product) if quantity == 0
         products_wishlist.update_attribute(:quantity, quantity)
       end
     end
  end

  # Returns the total quantity of this wishlist by default
  #
  # Returns the product's quantity if you precise a <i>Product</i> object in parameters
  #
  # ==== Parameters
  # * <tt>:product</tt> - a <i>Product</i> object
  def size(product=nil)
    if product.nil?
      return products_wishlists.inject(0) { |total, products_wishlist| total + products_wishlist.quantity }
    else
      products_wishlist = products_wishlists.find_by_product_id(product.id)
      return products_wishlist.quantity unless products_wishlist.nil?
    end
    return 0
  end

  # Returns product's count of this wishlist
  def count_products
    products.size
  end

  # Empty this wishlist
  def to_empty
    products_wishlists.destroy_all
  end

  # Returns true if wishlist is empty, returns false else
  def is_empty?
    count_products == 0
  end

  # Returns total price of this wishlist by default
  #
  # Returns total price of a <i>Product</i> in wishlist if you precise in parameters
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - add tax of price if true, false by default
  # * <tt>:product</tt> - a <i>Product</i> object
  def total(with_tax=false, product=nil)
    if product.nil?
      ProductsWishlist.find_all_by_wishlist_id(id).inject(0) { |total, products_wishlist| total + products_wishlist.total(with_tax) }
    else
      ProductsWishlist.find_all_by_wishlist_id_and_product_id(id, product.id).inject(0) { |total, products_wishlist| total + products_wishlist.total(with_tax) }
    end
  end

  # Returns weight of this wishlist
  def weight
    products.inject(0) { |total, product| total + product.weight }
  end

  # Returns all <i>ShippingMethodDetail</i> available for this wishlist
  def get_shipping_method_details
    shipping_method_details = []
    ShippingMethod.find(:all).each do |shipping_method|
      shipping_method_details += shipping_method.shipping_method_details.find(:all, :conditions => { :weight_min_lte => weight, :weight_max_gte => weight })
    end
    shipping_method_details
  end
end
