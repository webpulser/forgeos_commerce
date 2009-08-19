class AddTypeToTattribute < ActiveRecord::Migration
  def self.up
    add_column :tattributes, :type, :string
    
  end

  def self.down
    remove_column :tattributes, :type
  end
end
