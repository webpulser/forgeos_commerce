class OrdersController < ApplicationController
  layout false
  def index
    render :partial => 'list', :locals => { :orders => current_user.orders }
  end

  def show
    @order = current_user.orders.find_by_id(params[:id])
  end

  def destroy
    @order = current_user.orders.find_by_id(params[:id])
  end

  def remove_product
    @order = current_user.orders.find_by_id(params[:id])
  end

end
