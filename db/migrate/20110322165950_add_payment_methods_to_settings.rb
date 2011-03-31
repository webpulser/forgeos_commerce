class AddPaymentMethodsToSettings < ActiveRecord::Migration
  def self.up
    begin
      add_column :settings, :payment_methods, :text, :force => true
    rescue
      p "already exists"
    end
  end

  def self.down
    remove_column :settings, :payment_methods
  end
end
