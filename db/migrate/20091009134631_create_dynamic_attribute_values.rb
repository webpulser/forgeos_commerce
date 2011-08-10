class CreateDynamicAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :dynamic_attribute_values do |t|
      t.belongs_to :attribute,
        :product
      t.timestamps
    end
    add_index :dynamic_attribute_values, [:attribute_id, :product_id], :unique => true
    DynamicAttributeValue.create_translation_table!(:value=>:string)
  end

  def self.down
    DynamicAttributeValue.drop_translation_table!
    remove_index :dynamic_attribute_values, :columns => [:attribute_id, :product_id]
    drop_table :dynamic_attribute_values
  end
end
