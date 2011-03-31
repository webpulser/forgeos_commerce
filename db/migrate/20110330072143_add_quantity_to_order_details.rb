class AddQuantityToOrderDetails < ActiveRecord::Migration
  def self.up
    begin
      add_column :order_details, :quantity, :int
    rescue
      p "already exxists"
    end
  end

  def self.down
    remove_column :order_details, :quantity
  end
end
