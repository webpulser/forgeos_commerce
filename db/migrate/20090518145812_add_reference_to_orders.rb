class AddReferenceToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :reference, :string
  end

  def self.down
    remove_column :orders, :reference
  end
end
