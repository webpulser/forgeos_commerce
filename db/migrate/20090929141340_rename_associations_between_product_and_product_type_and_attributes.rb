class RenameAssociationsBetweenProductAndProductTypeAndAttributes < ActiveRecord::Migration
  def self.up
    rename_table :product_types_attributes, :attributes_product_types
    rename_table :products_attribute_values, :attribute_values_products
  end

  def self.down
    rename_table :attributes_product_types, :product_types_attributes
    rename_table :attribute_values_products, :products_attribute_values
  end
end
