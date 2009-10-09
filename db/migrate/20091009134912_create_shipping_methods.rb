class CreateShippingMethods < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :shipping_methods
  end
end
