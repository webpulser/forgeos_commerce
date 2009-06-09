class CreateCurrenciesExchangesRates < ActiveRecord::Migration
  def self.up
    create_table :currencies_exchanges_rates do |t|
      t.belongs_to :from_currency, :to_currency
      t.float :rate
      t.timestamps
    end
  end

  def self.down
    drop_table :currencies_exchanges_rates
  end
end
