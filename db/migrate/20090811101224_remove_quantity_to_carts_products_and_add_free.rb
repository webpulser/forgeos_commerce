class RemoveQuantityToCartsProductsAndAddFree < ActiveRecord::Migration
  def self.up
    remove_column :carts_products, :quantity
    add_column :carts_products, :free, :integer
  end

  def self.down
    add_column :carts_products, :quantity
    remove_column :carts_products, :free
  end
end
