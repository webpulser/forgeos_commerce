class DynamicTattributeValue < ActiveRecord::Base
  belongs_to :tattribute
  belongs_to :product_detail
end