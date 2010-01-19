class RemoveTranslationsToProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :name
    remove_column :products, :url
    remove_column :products, :description
  end

  def self.down
  end
end
