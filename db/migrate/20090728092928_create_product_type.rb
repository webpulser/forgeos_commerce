class CreateProductType < ActiveRecord::Migration
  def self.up
    create_table :product_types do |t|
      t.string :name
    end
    rename_table :product_parents_tattributes, :product_types_tattributes
    change_table :product_types_tattributes do |t|
      t.rename :product_parent_id, :product_type_id
    end
    change_table :products do |t|
      t.rename :product_id, :product_type_id
    end
  end

  def self.down
    drop_table :product_types
    change_table :product_types_tattributes do |t|
      t.rename :product_type_id, :product_parent_id
    end
    rename_table :product_types_tattributes, :product_parents_tattributes
    change_table :products do |t|
      t.rename :product_type_id, :product_id
    end
  end
end
