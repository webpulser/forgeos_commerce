class RenameTattributesToAttributes < ActiveRecord::Migration
  def self.up
    rename_table :tattributes, :attributes
    rename_table :dynamic_tattribute_values, :dynamic_attribute_values
    rename_table :tattribute_values, :attributes_values
    rename_table :attachments_tattributes, :attachments_attributes
    rename_table :attachments_tattribute_values, :attachments_attribute_values


    create_table :attribute_categories_attributes, :id => false do |t|
      t.belongs_to :attribute_category, :attribute
    end

    change_table :attributes do |t|
      t.belongs_to :element, :polymorphic => true
    end

  end

  def self.down
    rename_table :attributes, :tattributes
    rename_table :dynamic_attribute_values, :dynamic_tattribute_values
    rename_table :attributes_values, :tattribute_values
    rename_table :attachments_attributes, :attachments_tattributes
    rename_table :attachments_attribute_values, :attachments_tattribute_values
    
    drop_table :attribute_categories_attributes
    change_table :attribute do |t|
      t.remove_belongs_to :element
    end
  end
end
