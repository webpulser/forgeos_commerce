class CreateForms < ActiveRecord::Migration
  def self.up
    create_table :forms, :force => true do |t|
      t.string :name, :model
      t.belongs_to :page
      t.timestamps
    end
  end

  def self.down
    drop_table :forms
  end
end