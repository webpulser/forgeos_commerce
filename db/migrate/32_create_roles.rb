class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.string :name
    end
   
  end

  def self.down
    drop_table :roles
  end
end
