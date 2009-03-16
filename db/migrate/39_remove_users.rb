class RemoveUsers < ActiveRecord::Migration
  def self.up
    drop_table :users
  end

  def self.down
    create_table :users, :force => true do |t|
      t.string :email,
        :firstname,
        :lastname
      t.string :crypted_password,
        :salt,
        :remember_token,
        :activation_code,
        :limit => 40
      t.datetime :created_at,
        :updated_at,
        :remember_token_expires_at,
        :activated_at
      t.belongs_to :avatar
    end
  end
end
