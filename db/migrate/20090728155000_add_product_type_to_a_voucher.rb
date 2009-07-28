class AddProductTypeToAVoucher < ActiveRecord::Migration
  def self.up
    add_column :vouchers, :product_type_id, :integer
  end

  def self.down
    remove_column :vouchers, :product_type_id
  end
end
