class AddDescriptionToProductTypeTranslation < ActiveRecord::Migration
  def self.up
    add_column :product_type_translations, :description, :text
  end

  def self.down
    remove_column :product_type_translations, :description
  end
end
