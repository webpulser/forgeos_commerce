class CreateCartsItems < ActiveRecord::Migration
  def self.up
    create_table :carts_items do |t|
      t.belongs_to :cart,
        :product
      t.integer :quantity, :null => false, :default => 1
      t.string :size
    end
  end

  def self.down
    drop_table :carts_items
  end
end
