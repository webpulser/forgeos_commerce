class AddressesController < ApplicationController
  layout false
  def index
    render :partial => 'list', :locals => { :addresses => current_user.addresses }
  end

  def new
    @address = current_user.addresses.new(params[:address])
    render :action => 'create'
  end

  def create
    @address = current_user.addresses.new(params[:address])
    if @address.save
      flash[:notice] = I18n.t('address_create_ok').capitalize
      return render :partial => 'list', :locals => { :addresses => current_user.addresses }
    else
      flash[:error] = @address.errors
    end
  end

  def show
    @address = current_user.addresses.find_by_id(params[:id])
  end

  def edit
    @address = current_user.addresses.find_by_id(params[:id])
  end

  def update
    @address = current_user.addresses.find_by_id(params[:id])
    if @address.update_attributes(params[:address])
      flash[:notice] = I18n.t('address_update_ok').capitalize
      return render :partial => 'list', :locals => { :addresses => current_user.addresses }
    else
      flash[:error] = @address.errors
    end
    render :action => 'edit'
  end

  def destroy
    @address = current_user.addresses.find_by_id(params[:id])
    if @address.destroy
      flash[:notice] = I18n.t('address_update_ok').capitalize
    else
      flash[:error] = @address.errors
    end
    render :partial => 'list', :locals => { :addresses => current_user.addresses }
  end

end
