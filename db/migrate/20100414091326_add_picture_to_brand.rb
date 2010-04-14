class AddPictureToBrand < ActiveRecord::Migration
  def self.up
    change_table :brands do |t|
      t.belongs_to :picture
    end
  end

  def self.down
    remove_column :brands, :picture_id
  end
end
