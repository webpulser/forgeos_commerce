class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.boolean :dynamic, :default => false, :null => false
      t.string :access_method,
        :type
      t.belongs_to :element, :polymorphic => true
      t.timestamps
    end
    Attribute.create_translation_table!(:name=>:string)
  end

  def self.down
    Attribute.drop_translation_table!
    drop_table :attributes
  end
end
