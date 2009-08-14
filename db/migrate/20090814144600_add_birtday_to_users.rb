class AddBirtdayToUsers < ActiveRecord::Migration
  def self.up
    add_column :people, :birthday, :date
  end

  def self.down
    remove_column :people, :birthday, :date
  end
end
