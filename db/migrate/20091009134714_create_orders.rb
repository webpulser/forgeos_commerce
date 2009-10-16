class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.string :status,
        :transaction_number,
        :reference
      t.timestamps
    end  
  end

  def self.down
    drop_table :orders
  end
end
