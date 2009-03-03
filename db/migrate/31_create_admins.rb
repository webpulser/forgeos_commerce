class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.string :email, :hashed_password, :salt, :lastname, :firstname
      t.belongs_to :avatar

      t.timestamps
    end   
  end

  def self.down
    drop_table :admins
  end
end
