class CreateDynamicAttributes < ActiveRecord::Migration
  def self.up
    create_table :dynamic_attributes do |t|
      t.belongs_to :attributes_group, :product_detail
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :dynamic_attributes
  end
end
