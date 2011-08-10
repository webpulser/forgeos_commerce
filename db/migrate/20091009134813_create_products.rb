class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :type,
        :sku
      t.integer :stock, :default => 0
      t.float :price,
        :rate_tax,
        :default => 0.0,
        :null => false
      t.float :weight,
        :default => 0.0
      t.belongs_to :product_type,
        :brand,
        :redirection_product
      t.date :selling_date
      t.boolean :stop_sales,
        :offer_month,
        :on_first_page,
        :deleted,
        :default => false, :null => false
      t.boolean :active, :default => true, :null => false
      t.timestamps
    end
    add_index :products, [:sku, :active, :deleted]
    add_index :products, :sku, :uniq => true

    Product.create_translation_table!(:name => :string, :url => :string, :description => :text, :summary => :string)
  end

  def self.down
    Product.drop_translation_table!
    remove_index :products, :columns => [:sku, :active, :deleted]
    remove_index :products, :columns => [:sku]
    drop_table :products
  end
end
