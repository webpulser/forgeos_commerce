class ShippingMethod < ActiveRecord::Base
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  has_many :shipping_method_details
  validates_presence_of :name
end
