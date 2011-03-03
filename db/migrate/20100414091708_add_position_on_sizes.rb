class AddPositionOnSizes < ActiveRecord::Migration
  def self.up
    add_column :sizes, :position, :integer
  end

  def self.down
    remove_column :sizes, :position
  end
end
