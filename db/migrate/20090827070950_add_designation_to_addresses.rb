class AddDesignationToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :designation, :string
  end

  def self.down
    remove_column :addresses, :designation
  end
end
