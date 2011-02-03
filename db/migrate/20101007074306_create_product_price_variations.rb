class CreateProductPriceVariations < ActiveRecord::Migration
  def self.up
    create_table :product_price_variations do |t|
      t.belongs_to :product
      t.integer :quantity
      t.float :discount
    end
  end

  def self.down
    drop_table :product_price_variations
  end
end
