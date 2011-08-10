class CreateAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :attribute_values do |t|
      t.belongs_to :attribute
      t.integer :position
      t.timestamps
    end
    AttributeValue.create_translation_table!(:value=>:string)
  end

  def self.down
    AttributeValue.drop_translation_table!
    drop_table :attribute_values
  end
end
