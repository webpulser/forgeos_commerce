require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class OrderTest < Test::Unit::TestCase
  include RailsCommerce::CartHelper
  include RailsCommerce::ProductHelper

  #  need for UrlHelper in test context
  include ActionView::Helpers::TagHelper

  def setup
    $currency = RailsCommerce::Currency.find_by_name('euro')
    @user = RailsCommerce::User.find :first
    @product = RailsCommerce::ProductDetail.find 2
    RailsCommerce::Order.destroy_all
  end

  def create_order_template
    @order = RailsCommerce::Order.create(
      :user_id                => @user.id,
      :address_invoice_id     => @user.address_invoice.id, 
      :address_delivery_id    => @user.address_delivery.id,
      :shipping_method        => 'Shipping method',
      :shipping_method_price  => 0,
      :voucher                => 0
    )
    @order.orders_details << RailsCommerce::OrdersDetail.create(:name => @product.name, :description => @product.description, :price => @product.price(false, false), :rate_tax => @product.rate_tax, :quantity => 1)
  end

  def test_init_cart
    order = RailsCommerce::Order.new
    assert_instance_of RailsCommerce::Order, order
  end

  def test_order_requirement
    assert_no_difference 'RailsCommerce::Order.count' do
      order = RailsCommerce::Order.create
      assert order.errors.on(:user_id)
      assert order.errors.on(:address_invoice_id)
      assert order.errors.on(:address_delivery_id)
      assert order.errors.on(:shipping_method)
      assert order.errors.on(:shipping_method_price)
    end
  end

  def test_orders_detail_requirement
    assert_no_difference 'RailsCommerce::OrdersDetail.count' do
      orders_detail = RailsCommerce::OrdersDetail.create
      assert orders_detail.errors.on(:name)
      assert orders_detail.errors.on(:description)
      assert orders_detail.errors.on(:price)
      assert orders_detail.errors.on(:rate_tax)
      assert orders_detail.errors.on(:order_id)
      assert orders_detail.errors.on(:quantity)
    end
  end

  def test_create_order
    @order = RailsCommerce::Order.create(
      :user_id                => @user.id,
      :address_invoice_id     => @user.address_invoice.id, 
      :address_delivery_id    => @user.address_delivery.id,
      :shipping_method        => 'Shipping method',
      :shipping_method_price  => 0,
      :voucher                => 0
    )
    assert_equal RailsCommerce::Order.count, 1
    assert_equal @order.orders_details.size, 0
  end

  def test_create_order_with_orders_details
    create_order_template
    assert_equal RailsCommerce::Order.count, 1
    assert_equal @order.orders_details.size, 1
  end

  def test_order_total
    create_order_template
    assert_equal @order.total, 99.99
    assert_equal @order.total(true), 119.59
  end

  def test_order_total_currency
    create_order_template
    $currency = RailsCommerce::Currency.find_by_name('dollar')
    assert_equal @order.total, 150.36
    assert_equal @order.total(true), 179.84
  end

  def test_order_with_quantity
    create_order_template
    @order.orders_details.first.update_attribute :quantity, 2
    assert_equal @order.total, 199.98
    assert_equal @order.total(true), 239.18
  end

  def test_order_with_quantity
    create_order_template
    @order.orders_details.first.update_attribute :quantity, 2
    product = RailsCommerce::Product.find 284738923
    @order.orders_details << RailsCommerce::OrdersDetail.create(:name => product.name, :description => product.description, :price => product.price(false, false), :rate_tax => product.rate_tax, :quantity => 1)
    assert_equal @order.total, 249.97
    assert_equal @order.total(true), 298.97
  end

  def test_order_with_shippment_method_price
    create_order_template
    @order.update_attribute :shipping_method_price, 9.99
    # Problem 109.98 expected but was 109.98
    assert_equal @order.total.to_s, 109.98.to_s
    assert_equal @order.total(true), 129.58
  end
end
