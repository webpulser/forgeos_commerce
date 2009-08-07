class GeoZone < ActiveRecord::Base
  acts_as_tree

  has_many :vouchers
end
