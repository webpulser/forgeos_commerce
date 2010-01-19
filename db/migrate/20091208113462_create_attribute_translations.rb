class CreateAttributeTranslations < ActiveRecord::Migration
  def self.up
    Attribute.create_translation_table!(:name=>:string)
  end

  def self.down
    Attribute.drop_translation_table!
  end
end
