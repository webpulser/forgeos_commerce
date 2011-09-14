load File.join(Gem.loaded_specs['forgeos_core'].full_gem_path, 'app', 'helpers', 'application_helper.rb')
module ApplicationHelper
  def price_with_currency(price=0, precision=2)
    price = (price * current_currency.to_exchanges_rate(Currency::default).rate) unless current_currency.default?
    number_to_currency price, :precision => precision, :unit => current_currency.html
  end
end
