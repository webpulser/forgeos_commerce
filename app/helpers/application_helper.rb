module ApplicationHelper
  include CartHelper
  include WishlistHelper
  include ProductHelper
  include OrderHelper
  include CategoryHelper

  def price_with_currency(price=0, precision=2)
    number_to_currency price, :precision => precision, :unit => $currency.html
  end
end
