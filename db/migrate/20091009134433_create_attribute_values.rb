class CreateAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :attribute_values do |t|
      t.string :name
      t.belongs_to :attribute
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :attribute_values
  end
end
