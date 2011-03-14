class AttributesForms < ActiveRecord::Migration
  def self.up
    create_table :attributes_forms, :id => false do |t|
      t.integer :attribute_id, :form_id, :position
      t.boolean :validate
      t.timestamps
    end
  end

  def self.down
    drop_table :attributes_forms
  end
end