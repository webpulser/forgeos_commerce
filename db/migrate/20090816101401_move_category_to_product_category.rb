class MoveCategoryToProductCategory < ActiveRecord::Migration
  def self.up
    rename_table :categories_products, :product_categories_products
    change_table :product_categories_products do |t|
      t.rename :category_id, :product_category_id
      t.remove_timestamps
    end
  end

  def self.down
    change_table :product_categories_products do |t|
      t.rename :product_category_id, :category_id 
      t.timestamps
    end
    rename_table :product_categories_products, :categories_products
  end
end
