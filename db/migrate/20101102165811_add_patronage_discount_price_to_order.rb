class AddPatronageDiscountPriceToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :patronage_discount_price, :float
  end

  def self.down
    remove_column :orders, :patronage_discount_price
  end
end
