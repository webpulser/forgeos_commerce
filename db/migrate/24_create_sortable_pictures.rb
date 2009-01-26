class CreateSortablePictures < ActiveRecord::Migration
  def self.up
    create_table :sortable_pictures do |t|
      t.belongs_to :picture, :product, :category, :attributes_group, :attribute
      t.integer :position
    end
  end

  def self.down
    drop_table :sortable_pictures
  end
end
