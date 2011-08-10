class CreateAttributeValuesProducts < ActiveRecord::Migration
  def self.up
    create_table :attribute_values_products, :id => false do |t|
      t.belongs_to :attribute_value,
        :product
    end
    add_index :attribute_values_products, [:attribute_value_id, :product_id], :unique => true, :name => 'a_v_p_association'
  end

  def self.down
    remove_index :attribute_values_products, :name => 'a_v_p_association'
    drop_table :attribute_values_products
  end
end
