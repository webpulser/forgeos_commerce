class RenameProductParentAndDetailToProduct < ActiveRecord::Migration
  def self.up
    change_table :orders_details do |t|
      t.rename :product_detail_id, :product_id
    end
    rename_table :cross_sellings_product_parents, :cross_sellings_products
    change_table :cross_sellings_products do |t|
      t.rename :product_parent_id, :product_id
    end
    rename_table :product_details_tattribute_values, :products_tattribute_values
    change_table :products_tattribute_values do |t|
      t.rename :product_detail_id, :product_id
    end
    change_table :dynamic_tattribute_values do |t|
      t.rename :product_detail_id, :product_id
    end
  end

  def self.down
    change_table :orders_details do |t|
      t.rename :product_id, :product_detail_id
    end
    rename :cross_sellings_products, :cross_sellings_product_parents
    change_table :cross_sellings_product_parents do |t|
      t.rename :product_id, :product_parent_id
    end
    rename_table :products_tattribute_values, :product_details_tattribute_values
    change_table :product_details_tattribute_values do |t|
      t.rename :product_id, :product_detail_id
    end
    change_table :dynamic_tattribute_values do |t|
      t.rename :product_id, :product_detail_id
    end
  end
end
