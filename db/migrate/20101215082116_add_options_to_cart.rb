class AddOptionsToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :options, :text
  end

  def self.down
    remove_column :carts, :options
  end
end
