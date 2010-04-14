class AddBrandToProduct < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.belongs_to :brand
    end
  end

  def self.down
    remove_column :products, :brand_id
  end
end
