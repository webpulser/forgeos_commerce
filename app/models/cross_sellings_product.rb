class CrossSellingsProduct < ActiveRecord::Base
  belongs_to :cross_selling, :class_name => 'Product'
  belongs_to :product
end