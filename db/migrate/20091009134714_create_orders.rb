class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.string :status,
        :voucher,
        :transaction_number,
        :reference,
        :payment_type
      t.float :voucher_discount,
        :special_offer_discount,
        :patronage_discount_price
      t.boolean :payment_plans, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
