class AddStopSalesToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :stop_sales, :boolean
  end

  def self.down
    remove_column :products, :stop_sales
  end
end
