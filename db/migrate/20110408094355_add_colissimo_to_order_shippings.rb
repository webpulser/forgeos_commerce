class AddColissimoToOrderShippings < ActiveRecord::Migration
  def self.up
    add_column :order_shippings, :colissimo_type, :string, :default => 'DOS', :null => false
  end

  def self.down
    remove_column :order_shippings, :colissimo_type
  end
end
