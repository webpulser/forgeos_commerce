class RenameAttributesValuesToAttributeValues < ActiveRecord::Migration
  def self.up
    rename_table :attributes_values, :attribute_values
  end

  def self.down
    rename_table :attribute_values, :attributes_values
  end
end
