class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :name, :firstname, :address, :address_2, :zip_code, :city, :type
      t.belongs_to :civility, :country, :user
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
