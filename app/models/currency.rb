class Currency < ActiveRecord::Base

  has_many :to_exchanges_rates, :class_name => 'CurrenciesExchangesRate', :foreign_key => :from_currency_id, :dependent => :destroy
  has_many :from_exchanges_rates, :class_name => 'CurrenciesExchangesRate', :foreign_key => :to_currency_id, :dependent => :destroy

  def self.default
    Currency.find_by_default(true)
  end

  def to_exchanges_rate(currency)
    to_exchanges_rates.find_by_to_currency_id(currency.id)
  end
end
