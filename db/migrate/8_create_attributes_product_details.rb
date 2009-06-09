class CreateAttributesProductDetails < ActiveRecord::Migration
  def self.up
    create_table :attributes_product_details, :id => false do |t|
      t.belongs_to :attribute, :product_detail
    end
  end

  def self.down
    drop_table :attributes_product_details
  end
end
