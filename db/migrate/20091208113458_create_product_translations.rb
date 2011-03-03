class CreateProductTranslations < ActiveRecord::Migration
  def self.up
    Product.create_translation_table!(:name => :string, :url => :string, :description => :text)
  end

  def self.down
    Product.drop_translation_table!
  end
end
