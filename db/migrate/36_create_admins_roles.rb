class CreateAdminsRoles < ActiveRecord::Migration
  def self.up
    create_table :admins_roles, :id => false, :force => true do |t|
      t.belongs_to :admin, :role
    end
  end

  def self.down
    drop_table :admins_roles
  end
end
