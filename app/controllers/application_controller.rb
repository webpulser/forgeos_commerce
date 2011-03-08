class ApplicationController < ActionController::Base
  helper_method :current_currency
  # Change the currency
  def change_currency(currency_id)
    if currency = Currency.find_by_id(currency_id)
      session[:currency] = currency.id
    end
    redirect_to(:back)
  end

private

  def current_currency
    if Currency.table_exists?
      #TODO move default current to Setting
      if currency=(Currency.find_by_id(session[:currency]) || Currency.find_by_code('EUR'))
        $currency = currency
        session[:currency] = currency.id
        return currency
      end
    end
  end
end
