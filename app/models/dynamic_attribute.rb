class DynamicAttribute < ActiveRecord::Base
  belongs_to :attributes_group
  belongs_to :product_detail
end
