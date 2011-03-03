class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.boolean :dynamic, :default => false, :null => false
      t.string :access_method,
        :type,
        :name
      t.belongs_to :element, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :attributes
  end
end
