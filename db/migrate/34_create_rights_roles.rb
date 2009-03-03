class CreateRightsRoles < ActiveRecord::Migration    
  def self.up
    create_table :rights_roles, :id => false, :force => true do |t|
      t.belongs_to :right,:role
    end
  end

  def self.down
    drop_table :rights_roles
  end
end
