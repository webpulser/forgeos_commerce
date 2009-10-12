class UpdateCartsAndDropShippingMethods < ActiveRecord::Migration
  def self.up
    add_column :carts, :shipping_method_id, :integer
    drop_table :shipping_methods
  end

  def self.down
    remove_column :carts, :shipping_method_id
    create_table :shipping_methods do |t|
      t.string   :name
      t.float    :weight_min,
        :weight_max,
        :price,
        :price_min,
        :price_max
      t.belongs_to :transporter
      t.timestamps
    end
  end
end
