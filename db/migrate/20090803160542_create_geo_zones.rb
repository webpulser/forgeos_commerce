class CreateGeoZones < ActiveRecord::Migration
  def self.up
    drop_table :countries
    create_table :geo_zones do |t|
      t.string :iso,
        :iso3,
        :name,
        :printable_name,
        :type
      t.integer :numcode
      t.belongs_to :parent

    end
  end

  def self.down
    drop_table :geo_zones
    create_table :countries do |t|
      t.string :iso,
        :iso3,
        :name,
        :printable_name,
        :type
      t.integer :numcode
    end
  end
end
