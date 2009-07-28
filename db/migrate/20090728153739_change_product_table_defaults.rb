class ChangeProductTableDefaults < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.change :rate_tax, :float, :default => 0.0, :null => false
      t.change :price, :float, :default => 0.0, :null => false
      t.change :description, :text, :default => ''
    end
  end

  def self.down
    change_table :products do |t|
      t.change :rate_tax, :float, :default => nil, :null => true
      t.change :price, :float, :default => nil, :null => true
      t.change :description, :string, :default => nil
    end
  end
end
