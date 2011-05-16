class AddGoogleInfosToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :google_account, :text
    add_column :settings, :google_affiliation_store_name, :text
  end

  def self.down
    remove_column :settings, :google_affiliation_store_name
    remove_column :settings, :google_account
  end
end