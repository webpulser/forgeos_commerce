class CreateCrossSellingsProducts < ActiveRecord::Migration
  def self.up
    create_table :cross_sellings_products, :id => false do |t|
      t.belongs_to :cross_selling, :product
    end
  end

  def self.down
    drop_table :cross_sellings_products
  end
end
