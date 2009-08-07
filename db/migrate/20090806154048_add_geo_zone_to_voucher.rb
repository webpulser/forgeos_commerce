class AddGeoZoneToVoucher < ActiveRecord::Migration
  def self.up
    add_column :vouchers, :geo_zone_id, :integer
    add_column :vouchers, :using_after, :integer
  end

  def self.down
    remove_column :vouchers, :geo_zone_id, :integer
    remove_column :vouchers, :using_after, :integer
  end
end
