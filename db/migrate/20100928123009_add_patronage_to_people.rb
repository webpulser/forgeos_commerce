class AddPatronageToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :godfather_id, :integer
    add_column :people, :patronage_count, :integer, :default => 0, :nil => false
    add_column :settings, :godfather_discount_price, :float, :default => 0.0
    add_column :settings, :nephew_discount_price, :float, :default => 0.0
    add_column :settings, :godfather_discount_percent, :boolean, :default => false, :null => false
    add_column :settings, :nephew_discount_percent, :boolean, :default => false, :null => false

  end

  def self.down
    remove_column :people, :godfather_id
    remove_column :people, :patronage_count
    remove_column :settings, :nephew_discount_percent
    remove_column :settings, :godfather_discount_percent
    remove_column :settings, :nephew_discount_price
    remove_column :settings, :godfather_discount_price
  end
end
