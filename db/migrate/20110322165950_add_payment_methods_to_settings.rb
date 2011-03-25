class AddPaymentMethodsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :payment_methods, :text, :default => "--- \n"
  end

  def self.down
    remove_column :settings, :payment_methods
  end
end
