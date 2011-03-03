class AddSizeOnCartProducts < ActiveRecord::Migration
  def self.up
    add_column :carts_products, :size, :string
  end

  def self.down
    add_column :carts_products, :size
  end
end
