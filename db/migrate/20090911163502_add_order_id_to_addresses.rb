class AddOrderIdToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :order_id, :integer
  end

  def self.down
    remove_column :addresses, :order_id
  end
end
