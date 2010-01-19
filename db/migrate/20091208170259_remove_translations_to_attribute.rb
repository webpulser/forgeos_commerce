class RemoveTranslationsToAttribute < ActiveRecord::Migration
  def self.up
    remove_column :attributes, :name
  end

  def self.down
  end
end
