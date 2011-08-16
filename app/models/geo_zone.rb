load File.join(Gem.loaded_specs['forgeos_core'].full_gem_path, 'app', 'models', 'geo_zone.rb')
GeoZone.class_eval do
  has_many :vouchers
  has_and_belongs_to_many :transporter_rules
  has_and_belongs_to_many_attachments
end
