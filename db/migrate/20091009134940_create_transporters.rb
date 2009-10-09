class CreateTransporters < ActiveRecord::Migration
  def self.up
    create_table :transporters do |t|
      t.string :name,
        :description
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :transporters
  end
end
