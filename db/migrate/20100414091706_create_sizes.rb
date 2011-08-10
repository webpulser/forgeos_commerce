class CreateSizes < ActiveRecord::Migration
  def self.up
    create_table :sizes, :force => true do |t|
      t.string :name
      t.integer :quantity
      t.belongs_to :product
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :sizes
  end
end
