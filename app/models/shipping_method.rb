class ShippingMethod < ActiveRecord::Base
    
  belongs_to :transporter
  validates_presence_of :price, :name, :weight_min, :weight_max

  def fullname
    self.transporter ? "#{self.transporter.name}, #{self.name}" : self.name
  end

  def price(with_currency=true)
    return super if Currency::is_default? || !with_currency
    ("%01.2f" % (super * $currency.to_exchanges_rate(Currency::default).rate)).to_f
  end
end