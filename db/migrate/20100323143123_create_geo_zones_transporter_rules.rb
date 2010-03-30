class CreateGeoZonesTransporterRules < ActiveRecord::Migration
  def self.up
    create_table :geo_zones_transporter_rules, :id => false do |t|
      t.belongs_to :geo_zone
      t.belongs_to :transporter_rule
    end
  end

  def self.down
		drop_table :geo_zones_transporter_rules
  end
end
