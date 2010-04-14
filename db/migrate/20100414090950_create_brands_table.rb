class CreateBrandsTable < ActiveRecord::Migration
  def self.up
    create_table :brands do |t|
      t.string :name, :null =>false
      t.text   :description
      t.string :url
      t.string :code
      t.belongs_to :picture
    end
  end

  def self.down
    drop_table :brands
  end
end
