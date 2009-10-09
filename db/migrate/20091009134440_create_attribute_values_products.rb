class CreateAttributeValuesProducts < ActiveRecord::Migration
  def self.up
    create_table :attribute_values_products, :id => false do |t|
      t.belongs_to :attribute_value,
        :product
    end
  end

  def self.down
    drop_table :attribute_values_products
  end
end
