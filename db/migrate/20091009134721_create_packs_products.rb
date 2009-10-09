class CreatePacksProducts < ActiveRecord::Migration
  def self.up
    create_table :packs_products, :id => false do |t|
      t.belongs_to :pack, 
        :product
      t.integer :position
    end  
  end

  def self.down
    drop_table :packs_products
  end
end
