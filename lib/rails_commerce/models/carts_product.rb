module RailsCommerce
  # Relation between <i>RailsCommerce::Cart</i> and <i>RailsCommerce::Product</i>
  #
  # ==== belongs_to
  # * <tt>product</tt> - <i>RailsCommerce::Product</i>
  # * <tt>cart</tt> - <i>RailsCommerce::Cart</i>
  #
  # ==== attributes
  # * <tt>quantity</tt>
  class CartsProduct < ActiveRecord::Base
    set_table_name "rails_commerce_carts_products"
    
    belongs_to :product, :class_name => 'RailsCommerce::Product'
    belongs_to :cart, :class_name => 'RailsCommerce::Cart'

    validates_presence_of :cart_id, :product_id, :quantity

    # Return total price of this <i>RailsCommerce::Product</i>
    #
    # ==== Parameters
    # * <tt>:with_tax</tt> - false by default, returns total price <b>with tax</b> if true
    # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
    def total(with_tax=false, with_currency=true)
      ("%01.2f" % (product.price(with_tax, with_currency) * quantity)).to_f
    end

    # Returns total tax for this <i>RailsCommerce::Product</i>
    #
    # ==== Parameters
    # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
    def tax(with_currency=true)
      ("%01.2f" % (total(true, with_currency) - total)).to_f
    end
  end
end