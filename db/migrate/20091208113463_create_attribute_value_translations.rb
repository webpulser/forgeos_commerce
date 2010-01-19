class CreateAttributeValueTranslations < ActiveRecord::Migration
  def self.up
    AttributeValue.create_translation_table!(:name=>:string)
  end

  def self.down
    AttributeValue.drop_translation_table!
  end
end
