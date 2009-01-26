class HomeController < ApplicationController  
  def change_currency
    super(params[:id])
  end

  def change_design
    session[:design] = params[:design]
    redirect_to_home
  end
end
