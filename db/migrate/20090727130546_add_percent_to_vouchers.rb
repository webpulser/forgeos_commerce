class AddPercentToVouchers < ActiveRecord::Migration
  def self.up
    add_column :vouchers, :percent, :boolean
    add_column :vouchers, :offer_delivery, :boolean
    add_column :vouchers, :cumulable, :boolean
  end

  def self.down
    remove_column :vouchers, :percent
    remove_column :vouchers, :offer_delivery
    remove_column :vouchers, :cumulable
  end
end
