require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class CartTest < Test::Unit::TestCase
  include RailsCommerce::CartHelper
  include RailsCommerce::ProductHelper

  #  need for UrlHelper in test context
  include ActionView::Helpers::TagHelper

  def setup
    @cart = RailsCommerce::Cart.find(1)
    @cart.to_empty

    $currency = RailsCommerce::Currency.find_by_name('euro')
  end

  def test_init_cart
    cart = RailsCommerce::Cart.new
    assert_instance_of RailsCommerce::Cart, cart
  end

  def test_carts_product_requirement
    assert_no_difference 'RailsCommerce::Cart.count' do
      carts_product = RailsCommerce::CartsProduct.create
      assert carts_product.errors.on(:cart_id)
      assert carts_product.errors.on(:product_id)
      assert carts_product.errors.on(:quantity)
    end
  end

  # Test adding product_id in Cart
  def test_add_product
    @cart.add_product RailsCommerce::ProductParent.new
    @cart.add_product RailsCommerce::ProductParent.find(1)
    @cart.add_product RailsCommerce::ProductDetail.find(:first)

    assert_equal @cart.size, 1
  end

  # Test adding product_id in Cart
  def test_add_product_id
    @cart.add_product_id 2
    @cart.add_product_id "coucou"
    @cart.add_product_id RailsCommerce::ProductParent.find(3)
    @cart.add_product_id RailsCommerce::ProductDetail.find(:first)

    assert_equal @cart.size, 2
  end

  def test_add_same_product
    product = RailsCommerce::ProductDetail.find(2)
    @cart.add_product product
    @cart.add_product product

    assert_equal @cart.size, 2
    assert_equal @cart.count_products, 1
  end
  
  def test_set_quantity
    product = RailsCommerce::ProductDetail.find(2)
    @cart.add_product product

    assert_equal @cart.size, 1
    assert_equal @cart.count_products, 1

    @cart.set_quantity product, 5

    assert_equal @cart.size, 5
    assert_equal @cart.count_products, 1
    
    @cart.set_quantity product, 10

    assert_equal @cart.size, 10
    assert_equal @cart.count_products, 1
  end

  def test_add_product_with_quantity
    product = RailsCommerce::ProductDetail.find(2)
    @cart.add_product product, 5

    assert_equal @cart.size, 5
    
    @cart.add_product product, 5

    assert_equal @cart.size, 10
  end
  
  def test_size
    @cart.add_product RailsCommerce::ProductParent.new
    product_1 = RailsCommerce::ProductDetail.find(2)
    product_2 = RailsCommerce::ProductDetail.find(4)
    @cart.add_product product_1, 5
    @cart.add_product product_2

    assert_equal @cart.size, 6
    assert_equal @cart.size(product_1), 5
    assert_equal @cart.size(product_2), 1
  end
  
  def test_total
    product = RailsCommerce::ProductDetail.find(2)
    @cart.add_product product, 2
    @cart.add_product RailsCommerce::ProductDetail.find(4)
    
    assert_equal @cart.total.to_s, 219.97.to_s
    
    @cart.add_product RailsCommerce::ProductDetail.find(4)

    assert_equal @cart.total.to_s, 239.96.to_s
  end

  def test_total_by_product
    product1 = RailsCommerce::ProductDetail.find(2)
    product2 = RailsCommerce::ProductDetail.find(4)
    @cart.add_product product1, 2
    @cart.add_product product2
    
    assert_equal @cart.total(false, product1).to_s, 199.98.to_s
    assert_equal @cart.total(false, product2).to_s, 19.99.to_s
  end
  
  def test_total_with_tax
    product = RailsCommerce::ProductDetail.find(2)
    @cart.add_product product, 2
    @cart.add_product RailsCommerce::ProductDetail.find(4)
    
    assert_equal @cart.total(true).to_s, 263.09.to_s
    
    @cart.add_product RailsCommerce::ProductDetail.find(4)

    assert_equal @cart.total(true).to_s, 287.00.to_s
  end

  def test_total_by_product_with_tax
    product1 = RailsCommerce::ProductDetail.find(2)
    product2 = RailsCommerce::ProductDetail.find(4)
    @cart.add_product product1, 2
    @cart.add_product product2
    
    assert_equal @cart.total(true, product1).to_s, 239.18.to_s
    assert_equal @cart.total(true, product2).to_s, 23.91.to_s
  end

  def test_total_by_product_with_tax_and_a_different_currency
    $currency = RailsCommerce::Currency.find_by_name('dollar')
    product1 = RailsCommerce::ProductDetail.find(2)
    product2 = RailsCommerce::ProductDetail.find(4)
    @cart.add_product product1, 2
    @cart.add_product product2
    
    assert_equal @cart.total(true, product1).to_s, 359.68.to_s
    assert_equal @cart.total(true, product2).to_s, 35.96.to_s

    $currency = RailsCommerce::Currency.default
  end

  def test_to_empty
    assert_equal @cart.size, 0
  end
  
  def test_is_empty?
    assert @cart.is_empty?

    @cart.add_product RailsCommerce::ProductDetail.find(:first)

    assert !@cart.is_empty?

    @cart.to_empty

    assert @cart.is_empty?
  end
  
  def test_remove_product
    product1 = RailsCommerce::ProductDetail.find(2)
    product2 = RailsCommerce::ProductDetail.find(4)

    @cart.add_product product1
    @cart.remove_product_id 2

    assert @cart.is_empty?

    @cart.add_product product1, 4
    @cart.add_product product2
    @cart.remove_product product1
   
    assert_equal @cart.size, 1

    @cart.remove_product product2
    
    assert @cart.is_empty?
  end

# HELPER TEST
#  def test_display_cart
#    @cart.to_empty
#    assert_equal display_cart(@cart), "<div class='cart'><div class='cart_name'>ProductName</div><div class='cart_name'>Quantity</div><div class='cart_name'>Unit price</div><div class='cart_name'>Tax</div><div class='cart_name'>Total</div><div class='cart_total'><b>TOTAL: </b>0</div></div><div class='clear'></div>"
#    @cart.add_product RailsCommerce::Product.find(1)
#    assert_equal display_cart(@cart), "<div class='cart'><div class='cart_name'>ProductName</div><div class='cart_name'>Quantity</div><div class='cart_name'>Unit price</div><div class='cart_name'>Tax</div><div class='cart_name'>Total</div><div class='cart_product_line'><div class='cart_name'>Phone product</div><div class='cart_quantity'>1</div><div class='cart_price'>99.99</div><div class='cart_tax'>19.6</div><div class='cart_price'>119.59</div></div><div class='cart_total'><b>TOTAL: </b>119.59</div></div><div class='clear'></div>"
#    @cart.add_product RailsCommerce::Product.find(1)
#    assert_equal display_cart(@cart), "<div class='cart'><div class='cart_name'>ProductName</div><div class='cart_name'>Quantity</div><div class='cart_name'>Unit price</div><div class='cart_name'>Tax</div><div class='cart_name'>Total</div><div class='cart_product_line'><div class='cart_name'>Phone product</div><div class='cart_quantity'>2</div><div class='cart_price'>99.99</div><div class='cart_tax'>39.2</div><div class='cart_price'>239.18</div></div><div class='cart_total'><b>TOTAL: </b>239.18</div></div><div class='clear'></div>"
#    @cart.add_product RailsCommerce::Product.find(2)
#    assert_equal display_cart(@cart), "<div class='cart'><div class='cart_name'>ProductName</div><div class='cart_name'>Quantity</div><div class='cart_name'>Unit price</div><div class='cart_name'>Tax</div><div class='cart_name'>Total</div><div class='cart_product_line'><div class='cart_name'>Phone product</div><div class='cart_quantity'>2</div><div class='cart_price'>99.99</div><div class='cart_tax'>39.2</div><div class='cart_price'>239.18</div></div><div class='cart_product_line'><div class='cart_name'>DVD product</div><div class='cart_quantity'>1</div><div class='cart_price'>19.99</div><div class='cart_tax'>3.92</div><div class='cart_price'>23.91</div></div><div class='cart_total'><b>TOTAL: </b>263.09</div></div><div class='clear'></div>"
#    @cart.to_empty
#    assert_equal display_cart(@cart), "<div class='cart'><div class='cart_name'>ProductName</div><div class='cart_name'>Quantity</div><div class='cart_name'>Unit price</div><div class='cart_name'>Tax</div><div class='cart_name'>Total</div><div class='cart_total'><b>TOTAL: </b>0</div></div><div class='clear'></div>"
#  end
end
