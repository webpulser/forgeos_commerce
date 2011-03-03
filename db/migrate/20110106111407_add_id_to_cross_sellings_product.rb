class AddIdToCrossSellingsProduct < ActiveRecord::Migration
  def self.up
    change_table :cross_sellings_products do |t|
      t.column :id, :primary_key
    end
  end

  def self.down
    remove_column :cross_sellings_products, :id
  end
end
