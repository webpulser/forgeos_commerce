class AddQuantityToCartProducts < ActiveRecord::Migration
  def self.up
    add_column :carts_products, :quantity, :integer
  end

  def self.down
    remove_column :carts_products, :quantity
  end
end
