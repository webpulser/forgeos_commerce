class CreateCartsShippingMethodDetails < ActiveRecord::Migration
  def self.up
    create_table :carts_shipping_method_details, :id => false do |t|
      t.belongs_to :cart
        :shipping_method_detail
    end
  end

  def self.down
    drop_table :carts_shipping_method_details
  end
end
