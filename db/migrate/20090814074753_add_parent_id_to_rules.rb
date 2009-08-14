class AddParentIdToRules < ActiveRecord::Migration
  def self.up
    add_column :rules, :parent_id, :integer
  end

  def self.down
    remove_column :rules, :parent_id
  end
end
