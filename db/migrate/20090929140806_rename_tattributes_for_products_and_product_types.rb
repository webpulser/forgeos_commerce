class RenameTattributesForProductsAndProductTypes < ActiveRecord::Migration
  def self.up
    rename_table :product_types_tattributes, :product_types_attributes
    rename_table :products_tattribute_values, :products_attribute_values
  end

  def self.down
    rename_table :product_types_attributes, :product_types_tattributes
    rename_table :products_attribute_values, :products_tattribute_values
  end
end
