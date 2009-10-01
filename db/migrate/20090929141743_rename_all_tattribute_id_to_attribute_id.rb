class RenameAllTattributeIdToAttributeId < ActiveRecord::Migration
  def self.up
    rename_column :attachments_attributes , :tattribute_id, :attribute_id
    rename_column :attachments_attribute_values , :tattribute_value_id, :attribute_value_id
    rename_column :attributes_product_types , :tattribute_id, :attribute_id
    rename_column :attributes_values , :tattribute_id, :attribute_id
    rename_column :attribute_values_products , :tattribute_value_id, :attribute_value_id
    rename_column :dynamic_attribute_values , :tattribute_id, :attribute_id
  end

  def self.down
    rename_column :attachments_attributes , :attribute_id, :tattribute_id
    rename_column :attachments_attribute_values , :attribute_value_id, :tattribute_value_id
    rename_column :attributes_product_types , :attribute_id, :tattribute_id
    rename_column :attributes_values , :attribute_id, :tattribute_id
    rename_column :attribute_values_products , :attribute_value_id, :tattribute_value_id
    rename_column :dynamic_attribute_values , :attribute_id, :tattribute_id
  end
end
