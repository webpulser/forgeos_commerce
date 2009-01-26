class CreateOrdersDetails < ActiveRecord::Migration
  def self.up
    create_table :orders_details do |t|
      t.string :name, :description
      t.float :price, :rate_tax
      t.integer :quantity
      t.belongs_to :order
      t.timestamps
    end
  end

  def self.down
    drop_table :orders_details
  end
end
