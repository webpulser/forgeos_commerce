class CreateCrossSellingsProductParents < ActiveRecord::Migration
  def self.up
    create_table :cross_sellings_product_parents, :id => false do |t|
      t.belongs_to :cross_selling,:product_parent
    end
  end

  def self.down
    drop_table :cross_sellings_product_parents
  end
end
