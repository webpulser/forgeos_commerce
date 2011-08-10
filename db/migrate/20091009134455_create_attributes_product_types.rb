class CreateAttributesProductTypes < ActiveRecord::Migration
  def self.up
    create_table :attributes_product_types, :id => false do |t|
      t.belongs_to :attribute,
        :product_type
    end
    add_index :attributes_product_types, [:attribute_id, :product_type_id], :unique => true, :name => 'a_p_t_association'
  end

  def self.down
    remove_index :attributes_product_types, :name => 'a_p_t_association'
    drop_table :attributes_product_types
  end
end
