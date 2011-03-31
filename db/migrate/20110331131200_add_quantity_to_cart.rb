class AddQuantityToCart < ActiveRecord::Migration
  def self.up
    begin
      add_column :cart_items, :quantity, :int
    rescue
      p "already exxists"
    end
  end

  def self.down
    remove_column :cart_items, :quantity
  end
end
