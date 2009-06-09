class CreateNamables < ActiveRecord::Migration
  def self.up
    create_table :namables do |t|
      t.string :name, :type
      t.timestamps
    end
  end

  def self.down
    drop_table :namables
  end
end
