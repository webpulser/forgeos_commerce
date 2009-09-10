class AddSkuForOrdersDetails < ActiveRecord::Migration
  def self.up
    add_column :orders_details, :sku, :string
  end

  def self.down
    remove_column :orders_details, :sku
  end
end
