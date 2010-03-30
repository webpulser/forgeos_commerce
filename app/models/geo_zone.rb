require File.join(Rails.plugins['forgeos_core'].directory,'app','models','geo_zone')
class GeoZone < ActiveRecord::Base
  has_many :vouchers
  has_and_belongs_to_many :transporter_rules
  has_and_belongs_to_many_attachments
  
end
