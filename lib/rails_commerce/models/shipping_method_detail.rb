module RailsCommerce
  class ShippingMethodDetail < ActiveRecord::Base
    set_table_name "rails_commerce_shipping_method_details"
    
    belongs_to :shipping_method, :class_name => 'RailsCommerce::ShippingMethod'
    
    def price(with_currency=true)
      return super if Currency::is_default? || !with_currency
      ("%01.2f" % (super * $currency.to_exchanges_rate(Currency::default).rate)).to_f
    end
  end
end
