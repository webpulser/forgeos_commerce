class AddTransactionNumberToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :transaction_number, :string
  end

  def self.down
    remove_column :orders, :transaction_number
  end
end
