class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :content_type, :filename, :thumbnail
      t.integer :size, :parent_id, :width, :height, :db_file_id
    end
  end

  def self.down
    drop_table :pictures
  end
end
