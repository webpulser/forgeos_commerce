class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name,
        :type,
        :sku,
        :url
      t.integer :stock
      t.float :price,
        :rate_tax,
        :default => 0.0,
        :null => false
      t.float :weight,
        :default => 0.0
      t.belongs_to :product_type
      t.date :selling_date
      t.text :description
      t.boolean :stop_sales,
        :offer_month,
        :on_first_page,
        :deleted,
        :default => false, :null => false
      t.boolean :active, :default => true, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
