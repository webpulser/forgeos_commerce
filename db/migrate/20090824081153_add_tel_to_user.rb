class AddTelToUser < ActiveRecord::Migration
  def self.up
    add_column :people, :tel1, :string
    add_column :people, :tel2, :string
  end

  def self.down
    remove_column :people, :tel1
    remove_column :people, :tel2
  end
end
