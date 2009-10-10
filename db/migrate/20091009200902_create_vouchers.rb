class CreateVouchers < ActiveRecord::Migration
  def self.up
    create_table :vouchers do |t|
      t.string :name,
        :code
      t.float :value,
        :total_min
      t.date :date_start,
        :date_end
      t.boolean :percent,
        :offer_delivery,
        :cumulable
      t.belongs_to :product_type,
        :geo_zone
      t.integer :max_use,
        :using_after
      t.timestamps
    end  
  end

  def self.down
    drop_table :vouchers
  end
end
