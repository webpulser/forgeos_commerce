class CreateProductsTags < ActiveRecord::Migration
  def self.up
    create_table :products_tags, :id => false do |t|
      t.belongs_to :product, :tag
    end
  end

  def self.down
  end
end
