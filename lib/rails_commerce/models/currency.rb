module RailsCommerce
  class Currency < ActiveRecord::Base
    set_table_name "rails_commerce_currencies"
    
    has_many :to_exchanges_rates, :class_name => 'RailsCommerce::CurrenciesExchangesRate', :foreign_key => :from_currency_id
    has_many :from_exchanges_rates, :class_name => 'RailsCommerce::CurrenciesExchangesRate', :foreign_key => :to_currency_id
    
    def self.default
      Currency.find_by_default(true)
    end
    
    def self.is_default?
      return $currency.id == RailsCommerce::Currency.find_by_default(true).id
    end
    
    def to_exchanges_rate(currency)
      to_exchanges_rates.find_by_to_currency_id(currency.id)
    end
  end
end
