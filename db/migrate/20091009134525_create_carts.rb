class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.belongs_to  :user
      t.float    :discount
      t.integer  :percent
      t.timestamps
    end
  end

  def self.down
    drop_table :carts
  end
end
