class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.string :status,
        :shipping_method,
        :voucher,
        :transaction_number,
        :reference
      t.float :shipping_method_price
      t.timestamps
    end  
  end

  def self.down
    drop_table :orders
  end
end
