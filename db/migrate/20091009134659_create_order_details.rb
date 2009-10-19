class CreateOrderDetails < ActiveRecord::Migration
  def self.up
    create_table :order_details do |t|
      t.string :name,
        :description,
        :sku,
        :discount
      t.float :price,
        :rate_tax,
        :discount_price
      t.belongs_to :order,
        :product
      t.timestamps
    end
  end

  def self.down
    drop_table :order_details
  end
end
