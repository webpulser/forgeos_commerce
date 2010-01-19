class CreateDynamicAttributeTranslations < ActiveRecord::Migration
  def self.up
    DynamicAttributeValue.create_translation_table!(:value=>:string)
  end

  def self.down
    DynamicAttributeValue.drop_translation_table!
  end
end
