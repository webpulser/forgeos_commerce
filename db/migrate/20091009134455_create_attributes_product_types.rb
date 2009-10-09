class CreateAttributesProductTypes < ActiveRecord::Migration
  def self.up
    create_table :attributes_product_types, :id => false do |t|
      t.belongs_to :attribute,
        :product_type
    end
  end

  def self.down
    drop_table :attributes_product_types
  end
end
