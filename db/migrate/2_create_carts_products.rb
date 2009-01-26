class CreateCartsProducts < ActiveRecord::Migration
  def self.up
    create_table :carts_products do |t|
      t.belongs_to :cart, :product
      t.integer :quantity
    end
  end

  def self.down
    drop_table :carts_products
  end
end
