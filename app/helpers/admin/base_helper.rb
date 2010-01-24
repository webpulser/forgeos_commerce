module Admin::BaseHelper
  def price_with_currency(price=0, precision=2)
    "#{number_with_precision(price,:precision => precision)} #{$currency.html}"
  end
end
