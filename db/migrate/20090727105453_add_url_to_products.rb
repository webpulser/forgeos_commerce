class AddUrlToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :url, :string
  end

  def self.down
    remove_column :products, :url
  end
end
