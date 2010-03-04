class RemoveTranslationsToAttributeValues < ActiveRecord::Migration
  def self.up
    remove_column :attribute_values, :name
  end

  def self.down
    add_column :attribute_values, :name, :string
  end
end
