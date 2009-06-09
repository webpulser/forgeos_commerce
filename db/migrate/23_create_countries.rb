class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :iso, :size => 2
      t.string :iso3, :size => 3
      t.string :name,:printable_name, :size => 80
      t.integer :numcode
    end
  end

  def self.down
    drop_table :countries
  end
end
