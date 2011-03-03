class RemoveTranslatedFieldsToProductType < ActiveRecord::Migration
  def self.up
    remove_column :product_types, :name
  end

  def self.down
    add_column :product_types, :name, :string
  end
end
