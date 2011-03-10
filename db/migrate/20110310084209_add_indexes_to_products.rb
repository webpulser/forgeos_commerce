class AddIndexesToProducts < ActiveRecord::Migration
  def self.up
    add_index :products, [:sku, :active, :deleted]
    add_index :products, :sku, :uniq => true
    add_index :attribute_values_products, [:attribute_value_id, :product_id], :unique => true
    add_index :attributes_product_types, [:attribute_id, :product_type_id], :unique => true
    add_index :dynamic_attribute_values, [:attribute_id, :product_id], :unique => true
  end

  def self.down
    remove_index :products, :column => [:sku, :active, :deleted]
    remove_index :products, :sku
    remove_index :attribute_values_products, :column => [:attribute_value_id, :product_id]
    remove_index :dynamic_attribute_values, :column => [:attribute_id, :product_id]
    remove_index :attributes_product_types, :column => [:attribute_id, :product_type_id]
  end
end
