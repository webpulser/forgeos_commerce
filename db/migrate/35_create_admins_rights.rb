class CreateAdminsRights < ActiveRecord::Migration
  def self.up
    create_table :admins_rights, :id => false, :force => true do |t|
      t.belongs_to :admin, :right
    end
  end

  def self.down
    drop_table :admins_rights
  end
end
