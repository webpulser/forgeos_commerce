class AddDiscountToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :discount, :float
    add_column :carts, :percent, :integer
  end

  def self.down
    remove_column :carts, :discount
    remove_column :carts, :percent
  end
end