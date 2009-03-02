class CreateProductsWishlists < ActiveRecord::Migration
  def self.up
    create_table :products_wishlists do |t|
      t.belongs_to :wishlist, :product
      t.integer :quantity
    end
  end

  def self.down
    drop_table :products_wishlists
  end
end
