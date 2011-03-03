class AddRedirectionProductIdToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :redirection_product_id, :integer
  end

  def self.down
    remove_column :products, :redirection_product_id
  end
end
