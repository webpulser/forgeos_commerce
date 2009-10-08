class AddPositionToAttributeValues < ActiveRecord::Migration
  def self.up
    add_column :attribute_values, :position, :integer
  end

  def self.down
    remove_column :attribute_values, :position
  end
end
