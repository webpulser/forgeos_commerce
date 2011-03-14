class RenameCartsProductsIntoCartItems < ActiveRecord::Migration
  def self.up
    rename_table :carts_products, :cart_items
  end

  def self.down
    rename_table :cart_items, :carts_products
  end
end
