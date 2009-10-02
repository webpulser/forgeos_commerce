class RenameShippingMethodsToTransportersAndShippingMethodDetailsToShippingMethods < ActiveRecord::Migration
  def self.up
    rename_table :shipping_methods, :transporters
    rename_table :shipping_method_details, :shipping_methods
    rename_column :shipping_methods , :shipping_method_id, :transporter_id
  end

  def self.down
    rename_table :transporters, :shipping_methods
    rename_table :shipping_methods, :shipping_method_details
  end
end
