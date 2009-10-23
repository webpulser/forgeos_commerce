class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.string :status,
        :voucher,
        :transaction_number,
        :reference
      t.float :voucher_discount,
        :special_offer_discount
      t.timestamps
    end  
  end

  def self.down
    drop_table :orders
  end
end
