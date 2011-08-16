load File.join(Gem.loaded_specs['forgeos_core'].full_gem_path, 'app', 'models', 'country.rb')
Country.class_eval do
  has_and_belongs_to_many :transporter_rules, :join_table => 'geo_zones_transporter_rules', :foreign_key => 'geo_zone_id'
end
