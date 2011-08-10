class CreateCrossSellingsProducts < ActiveRecord::Migration
  def self.up
    create_table :cross_sellings_products do |t|
      t.belongs_to :cross_selling, :product
    end
  end

  def self.down
    drop_table :cross_sellings_products
  end
end
