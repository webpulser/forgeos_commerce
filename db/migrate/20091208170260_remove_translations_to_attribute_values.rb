class RemoveTranslationsToAttributeValues < ActiveRecord::Migration
  def self.up
    remove_column :attribute_values, :name
  end

  def self.down
  end
end
