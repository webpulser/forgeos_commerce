class CreateOrderDetails < ActiveRecord::Migration
  def self.up
    create_table :order_details do |t|
      t.string :name,
        :description,
        :sku,
        :voucher_discount,
        :special_offer_discount
      t.float :price,
        :rate_tax,
        :voucher_discount_price,
        :special_offer_discount_price,
        :packaging_price
      t.belongs_to :order,
        :product
      t.integer :quantity, :default => 1, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :order_details
  end
end
