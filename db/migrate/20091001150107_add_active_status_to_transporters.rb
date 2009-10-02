class AddActiveStatusToTransporters < ActiveRecord::Migration
  def self.up
    add_column :transporters, :active, :boolean
  end

  def self.down
    remove_column :transporters, :active
  end
end
