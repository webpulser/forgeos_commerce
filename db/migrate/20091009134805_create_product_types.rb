class CreateProductTypes < ActiveRecord::Migration
  def self.up
    create_table :product_types
    ProductType.create_translation_table!(:name=> :string, :url => :string, :description => :text)
  end

  def self.down
    ProductType.drop_translation_table!
    drop_table :product_types
  end
end
