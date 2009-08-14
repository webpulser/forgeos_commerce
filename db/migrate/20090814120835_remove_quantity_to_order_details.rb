class RemoveQuantityToOrderDetails < ActiveRecord::Migration
  def self.up
    remove_column :orders_details, :quantity
  end

  def self.down
    add_culumn :orders_details, :quantity, :integer
  end
end
