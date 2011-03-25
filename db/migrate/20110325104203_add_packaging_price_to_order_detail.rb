class AddPackagingPriceToOrderDetail < ActiveRecord::Migration
  def self.up
    add_column :order_details, :packaging_price, :float
  end

  def self.down
    remove_column :order_details, :packaging_price
  end
end
