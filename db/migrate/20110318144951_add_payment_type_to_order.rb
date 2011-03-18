class AddPaymentTypeToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :payment_type, :string
  end

  def self.down
    remove_column :orders, :payment_type
  end
end