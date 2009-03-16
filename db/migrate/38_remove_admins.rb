class RemoveAdmins < ActiveRecord::Migration
  def self.up
    drop_table :admins
  end

  def self.down
    create_table :admins do |t|
      t.string :email, :hashed_password, :salt, :lastname, :firstname
      t.belongs_to :avatar

      t.timestamps
    end   
  end
end
