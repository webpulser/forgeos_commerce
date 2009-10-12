class ShippingMethodRule < Rule

  belongs_to :transporter

#  def price(with_currency=true)
#    return super if Currency::is_default? || !with_currency
#    ("%01.2f" % (super * $currency.to_exchanges_rate(Currency::default).rate)).to_f
#  end
end