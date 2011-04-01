class AddQuantityToOrderDetails < ActiveRecord::Migration
  def self.up
    begin
      add_column :order_details, :quantity, :int, :default => 1
    rescue
      change_column :order_details, :quantity, :int, :default => 1
    end
  end

  def self.down
    remove_column :order_details, :quantity
  end
end
