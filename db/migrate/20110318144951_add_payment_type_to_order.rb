class AddPaymentTypeToOrder < ActiveRecord::Migration
  def self.up
    begin
      add_column :orders, :payment_type, :string
    rescue
      p "already exists"
    end
  end

  def self.down
    remove_column :orders, :payment_type
  end
end