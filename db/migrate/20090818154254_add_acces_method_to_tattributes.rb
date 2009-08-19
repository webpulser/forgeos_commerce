class AddAccesMethodToTattributes < ActiveRecord::Migration
  def self.up
    add_column :tattributes, :access_method, :string
  end

  def self.down
    remove_column :tattributes, :access_method
  end
end
