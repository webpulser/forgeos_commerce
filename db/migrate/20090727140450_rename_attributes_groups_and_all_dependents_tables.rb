class RenameAttributesGroupsAndAllDependentsTables < ActiveRecord::Migration
  def self.up
    rename_table :attributes_groups, :tattributes
    rename_table :dynamic_attributes, :dynamic_tattribute_values
    rename_table :attributes, :tattribute_values
    rename_table :attributes_groups_product_parents, :product_parents_tattributes
    rename_table :attributes_product_details, :product_details_tattribute_values

    change_table :product_details_tattribute_values do |t|
      t.rename :attribute_id, :tattribute_value_id
    end
    change_table :product_parents_tattributes do |t|
      t.rename :attributes_group_id, :tattribute_id
    end
    change_table :tattribute_values do |t|
      t.rename :attributes_group_id, :tattribute_id
    end
    change_table :dynamic_tattribute_values do |t|
      t.rename :attributes_group_id, :tattribute_id
    end
  end

  def self.down
    change_table :product_details_tattributes_values do |t|
      t.rename :attribute_value_id, :attribute_id
    end
    change_table :product_parents_tattributes do |t|
      t.rename :tattribute_id, :attributes_group_id
    end
    change_table :tattribute_values do |t|
      t.rename :tattribute_id, :attributes_group_id
    end
    change_table :dynamic_tattribute_values do |t|
      t.rename :tattribute_id, :attributes_group_id
    end

    rename_table :tattributes, :attributes_groups
    rename_table :dynamic_tattribute_values, :dynamic_attributes
    rename_table :tattribute_values, :attributes 
    rename_table :product_parents_tattributes, :attributes_groups_product_parents 
    rename_table :product_details_tattribute_values, :attributes_product_details 
  end
end
