class AddNewPriceToCartsProduct < ActiveRecord::Migration
  def self.up
    add_column :carts_products, :new_price, :float
  end
  
  def self.down
    remove_column :carts_products, :new_price
  end
end
