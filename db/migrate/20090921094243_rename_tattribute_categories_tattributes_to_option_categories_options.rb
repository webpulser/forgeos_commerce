class RenameTattributeCategoriesTattributesToOptionCategoriesOptions < ActiveRecord::Migration
  def self.up
    rename_table :tattribute_categories_tattributes, :option_categories_options
    change_table :option_categories_options do |t|
      t.rename :tattribute_id, :option_id
      t.rename :tattribute_category_id, :option_category_id
    end
  end

  def self.down
    change_table :option_categories_options do |t|
      t.rename :option_id, :tattribute_id
      t.rename :option_category_id, :tattribute_category_id
    end
    rename_table :option_categories_options, :tattribute_categories_tattributes
  end
end
