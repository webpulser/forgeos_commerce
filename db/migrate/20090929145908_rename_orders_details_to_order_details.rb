class RenameOrdersDetailsToOrderDetails < ActiveRecord::Migration
  def self.up
    rename_table :orders_details, :order_details
  end

  def self.down
    rename_table :order_details, :orders_details
  end
end
