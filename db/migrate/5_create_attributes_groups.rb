class CreateAttributesGroups < ActiveRecord::Migration
  def self.up
    create_table :attributes_groups do |t|
      t.string :name
      t.boolean :dynamic
      t.timestamps
    end
  end

  def self.down
    drop_table :attributes_groups
  end
end
