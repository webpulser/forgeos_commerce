require File.join(Rails.plugins['forgeos_core'].directory,'app','models','country')

class Country < GeoZone
  has_and_belongs_to_many :transporter_rules, :join_table => 'geo_zones_transporter_rules', :foreign_key => 'geo_zone_id'
end