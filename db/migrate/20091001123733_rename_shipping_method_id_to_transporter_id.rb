class RenameShippingMethodIdToTransporterId < ActiveRecord::Migration
  def self.up
    rename_column :shipping_methods , :shipping_method_id, :transporter_id
  end

  def self.down
    rename_column :shipping_methods, :transporter_id, :shipping_method_id
  end
end
