class CreateProductTypeCategoriesProductTypes < ActiveRecord::Migration
  def self.up
    create_table :product_type_categories_product_types, :id => false do |t|
      t.belongs_to :product_type_category, :product_type
    end
  end

  def self.down
    drop_table :product_type_categories_product_types
  end
end
