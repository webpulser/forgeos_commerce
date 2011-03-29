class AddPaymentMethodsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :payment_methods, :text
  end

  def self.down
    remove_column :settings, :payment_methods
  end
end
