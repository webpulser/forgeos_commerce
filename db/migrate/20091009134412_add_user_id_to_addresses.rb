class AddUserIdToAddresses < ActiveRecord::Migration
  def self.up
    change_table :addresses do |t|
      t.string :name,
        :firstname,
        :designation
      t.integer :civility
      t.belongs_to :user,
        :order
    end
  end

  def self.down
    change_table :addresses do |t|
      t.remove :name, :firstname, :designation, :civility, :user_id, :order_id
    end
  end
end
