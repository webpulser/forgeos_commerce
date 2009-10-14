class CreateCartsShippingMethods < ActiveRecord::Migration
  def self.up
    create_table :carts_shipping_methods, :id => false do |t|
      t.belongs_to :cart
        :shipping_method
    end
  end

  def self.down
    drop_table :carts_shipping_methods
  end
end
