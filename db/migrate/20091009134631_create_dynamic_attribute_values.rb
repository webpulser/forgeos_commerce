class CreateDynamicAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :dynamic_attribute_values do |t|
      t.belongs_to :attribute,
        :product
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :dynamic_attribute_values
  end
end
