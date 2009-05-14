class AddProductIdToOrdersDetails < ActiveRecord::Migration
  def self.up
    add_column :orders_details, :product_detail_id, :integer
  end

  def self.down
    remove_column :orders_details, :product_detail_id
  end
end
