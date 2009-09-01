class RemoveQuantityFromCartsProduct < ActiveRecord::Migration
  def self.up
    remove_column :carts_products, :quantity
  end

  def self.down
    add_column :carts_products, :quantity, :integer
  end
end
