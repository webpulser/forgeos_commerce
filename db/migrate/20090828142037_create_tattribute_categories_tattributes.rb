class CreateTattributeCategoriesTattributes < ActiveRecord::Migration
  def self.up
    create_table :tattribute_categories_tattributes, :id => false do |t|
      t.belongs_to :tattribute_category, :tattribute
    end
  end

  def self.down
    drop_table :tattribute_categories_tattributes
  end
end
