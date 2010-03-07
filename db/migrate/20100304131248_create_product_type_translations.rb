class CreateProductTypeTranslations < ActiveRecord::Migration
  def self.up
    ProductType.create_translation_table!(:name=>:string,:url=>:string, :description => :text)
  end

  def self.down
    ProductType.drop_translation_table!
  end
end
