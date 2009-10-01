class CreateUserCategoriesUsers < ActiveRecord::Migration
  def self.up
    create_table :user_categories_users, :id => false do |t|
      t.belongs_to :user_category, :user
    end
  end

  def self.down
    drop_table :user_categories_users
  end
end
