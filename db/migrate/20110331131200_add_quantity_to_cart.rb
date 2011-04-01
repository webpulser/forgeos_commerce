class AddQuantityToCart < ActiveRecord::Migration
  def self.up
    begin
      add_column :cart_items, :quantity, :int, :default => 1
    rescue
      change_column :cart_items, :quantity, :int, :default => 1
    end
  end

  def self.down
    remove_column :cart_items, :quantity
  end
end
