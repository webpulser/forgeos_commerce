class CreateAttributesGroupsProductParents < ActiveRecord::Migration
  def self.up
    create_table :attributes_groups_product_parents, :id => false do |t|
      t.belongs_to :attributes_group, :product_parent
    end
  end

  def self.down
    drop_table :attributes_groups_product_parents
  end
end
