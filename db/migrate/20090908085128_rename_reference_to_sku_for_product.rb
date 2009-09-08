class RenameReferenceToSkuForProduct < ActiveRecord::Migration
  def self.up
    rename_column :products, :reference, :sku
  end

  def self.down
    rename_column :products, :sku, :reference
  end
end
