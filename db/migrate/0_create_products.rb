class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name, :description, :type, :reference, :barcode, :stock
      t.float :price, :rate_tax
      t.boolean :offer_month, :on_first_page
      t.integer :product_id
      t.float :weight, :default => 0.0
      t.date :selling_date
      t.text :keywords
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
