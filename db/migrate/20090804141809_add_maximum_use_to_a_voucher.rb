class AddMaximumUseToAVoucher < ActiveRecord::Migration
  def self.up
    add_column :vouchers, :max_use, :integer
  end

  def self.down
    remove_column :vouchers, :max_use, :integer
  end
end
