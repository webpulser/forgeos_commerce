require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class ProductTest < Test::Unit::TestCase
  include RailsCommerce::CartHelper
  include RailsCommerce::ProductHelper

#  need for UrlHelper in test context
  include ActionView::Helpers::TagHelper

  def setup
    $currency = RailsCommerce::Currency.find_by_name('euro')
  end

  def test_description
    assert_equal RailsCommerce::ProductDetail.find(2).description, "The telephone is a telecommunications device that is used to transmit and receive sound (most commonly speech), usually two people conversing but occasionally three or more."
  end
  
  def test_price
    assert_equal RailsCommerce::ProductDetail.find(2).price, 99.99
  end

  def test_price_with_tax_and_different_currency
    $currency = RailsCommerce::Currency.find_by_name('dollar')
    assert_equal RailsCommerce::ProductDetail.find(2).price(true), 179.84
  end

  def test_price_with_tax
    assert_equal RailsCommerce::ProductDetail.find(2).price(true), 119.59
  end
  
  def test_attributes_groups
    assert_equal 3, RailsCommerce::ProductParent.find(1).attributes_groups.size
  end

  def test_products_details
    product_details = RailsCommerce::ProductParent.find(1).product_details
    assert_equal product_details.size, 3
    description = "The telephone is a telecommunications device that is used to transmit and receive sound (most commonly speech), usually two people conversing but occasionally three or more."
    product_details.each do |product|
      assert_equal product.description, description
    end
  end

  # test if a RailsCommerce::ProductParent have one RailsCommerce::ProductDetail after creation.
  def test_product_parent_creation
    product_parent = RailsCommerce::ProductParent.create
    assert_equal 1, product_parent.product_details.count
  end

  # test if a created RailsCommerce::ProductDetail's dynamic_attributes count
  # is equal to his RailsCommerce::ProductParent's dynamic_attributes_groups size
  def test_product_detail_creation
    product_parent = RailsCommerce::ProductParent.find(1)
    product_detail = product_parent.product_details.create
    assert_equal product_parent.dynamic_attributes_groups.size, product_detail.dynamic_attributes.count
  end

  # test if all RailsCommerce::DynamicAttribute associated with a RailsCommerce::ProductDetail
  # was destroyed after RailsCommerce::ProductDetail destroy
  def test_product_detail_destroy
    product_detail = RailsCommerce::ProductParent.find(1).product_details.create
    product_detail_id = product_detail.id
    assert_not_equal nil, product_detail.destroy
    assert_equal 0, RailsCommerce::DynamicAttribute.count(:conditions => ['product_detail_id = ?',product_detail_id])
  end

  # test if a RailsCommerce::ProductParent have always at least one RailsCommerce::ProductDetail.
  def test_product_details_destroy
    product_details = RailsCommerce::ProductParent.find(1).product_details
    assert_equal 3, product_details.size
    product_details.first.destroy
    assert_equal 2, product_details.size
    product_details.first.destroy
    assert_equal 1, product_details.size
    product_details.first.destroy
    assert_equal 1, product_details.size
  end

  # test if all RailsCommerce::ProductDetails was destroyed after there RailsCommerce::ProductParent destroy.
  def test_product_parent_destroy
    product_parent = RailsCommerce::ProductParent.find(1)
    assert_not_equal nil, product_parent.destroy
    assert_equal 0, RailsCommerce::ProductDetail.count(:conditions => ['product_id = ?',1])
  end
end
