class AddPriceminAndPricemaxToShippingMethodDetails < ActiveRecord::Migration
  def self.up
    add_column :shipping_method_details, :price_min, :float
    add_column :shipping_method_details, :price_max, :float
  end

  def self.down
    remove_column :shipping_method_details, :price_min
    remove_column :shipping_method_details, :price_max
  end
end
