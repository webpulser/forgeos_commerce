class ShippingMethodDetail < ActiveRecord::Base
  
  belongs_to :shipping_method
  
  def price(with_currency=true)
    return super if Currency::is_default? || !with_currency
    ("%01.2f" % (super * $currency.to_exchanges_rate(Currency::default).rate)).to_f
  end
end
