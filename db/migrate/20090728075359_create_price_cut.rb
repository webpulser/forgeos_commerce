class CreatePriceCut < ActiveRecord::Migration
  def self.up
    create_table :price_cuts do |t|
      t.float :old_price, :new_price
      t.date :date_start, :date_end
      t.belongs_to :product
    end
  end

  def self.down
    drop_table :price_cuts
  end
end
