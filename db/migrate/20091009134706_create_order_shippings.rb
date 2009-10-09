class CreateOrderShippings < ActiveRecord::Migration
  def self.up
    create_table :order_shippings do |t|
      t.string :name,
        :track_number
      t.float :price
      t.belongs_to :order
      t.timestamps
    end
  end

  def self.down
    drop_table :order_shippings
  end
end
