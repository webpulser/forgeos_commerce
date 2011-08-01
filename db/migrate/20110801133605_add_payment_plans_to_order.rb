class AddPaymentPlansToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :payment_plans, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :orders, :payment_plans
  end
end
