class CreateShippingMethodsDetails < ActiveRecord::Migration
  def self.up
    create_table :shipping_method_details do |t|
      t.string :name
      t.float :weight_min, :weight_max, :price
      t.belongs_to :shipping_method
      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_methods_details
  end
end
