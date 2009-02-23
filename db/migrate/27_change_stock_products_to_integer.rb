class ChangeStockProductsToInteger < ActiveRecord::Migration
  def self.up
    change_column :products, :stock, :integer
  end

  def self.down
    change_column :products, :stock, :string
  end
end
