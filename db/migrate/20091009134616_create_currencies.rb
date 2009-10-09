class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :name,
        :html,
        :code
      t.boolean  :default
      t.timestamps
    end  
  end

  def self.down
    drop_table :currencies
  end
end
