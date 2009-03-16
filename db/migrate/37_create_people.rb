class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people, :force => true do |t|
      t.string :email,
        :firstname,
        :lastname,
        :type
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

  def self.down
    drop_table :people
  end
end
