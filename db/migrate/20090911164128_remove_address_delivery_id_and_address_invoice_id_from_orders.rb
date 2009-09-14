class RemoveAddressDeliveryIdAndAddressInvoiceIdFromOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :address_delivery_id
    remove_column :orders, :address_invoice_id
  end

  def self.down
    add_column :orders, :address_delivery_id, :integer
    add_column :orders, :address_invoice_id, :integer
  end
end
