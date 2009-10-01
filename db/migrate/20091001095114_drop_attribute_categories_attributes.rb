class DropAttributeCategoriesAttributes < ActiveRecord::Migration
  def self.up
    drop_table :attribute_categories_attributes
    drop_table :user_categories_users
  end

  def self.down
  end
end
