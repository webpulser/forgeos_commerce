class Admin::ShippingMethodsController < Admin::BaseController
  def index
    @shipping_methods = ShippingMethod.all
  end

  def new
    @shipping_method = ShippingMethod.new(params[:shipping_method])
    render :action => 'create'
  end

  def create
    @shipping_method = ShippingMethod.new(params[:shipping_method])
    if @shipping_method.save
      flash[:notice] = I18n.t('shipping_method.create.success').capitalize
      redirect_to(:action => 'index')
    else
      flash[:error] = I18n.t('shipping_method.create.failed').capitalize
    end
  end
  
  def show
    @shipping_method = ShippingMethod.find_by_id(params[:id])
  end

  def edit
    @shipping_method = ShippingMethod.find_by_id(params[:id])
  end

  def update
    @shipping_method = ShippingMethod.find_by_id(params[:id])
    if @shipping_method.update_attributes(params[:shipping_method])
      flash[:notice] = I18n.t('shipping_method.update.success').capitalize
    else
      flash[:error] = I18n.t('shipping_method.update.failed').capitalize
    end
    render :action => 'edit'
  end

  def destroy
    @shipping_method = ShippingMethod.find_by_id(params[:id])
    if @shipping_method.destroy
      index
      render :partial => 'list', :locals => { :shipping_methods => @shipping_methods }
    end
  end

  def create_detail
    shipping_method = ShippingMethod.find_by_id(params[:id])
    @shipping_method_detail = shipping_method.shipping_method_details.new(params[:shipping_method_detail])
    if request.post?
      if @shipping_method_detail.save
        flash[:notice] = I18n.t('shipping_method_detail.create.success').capitalize
        redirect_to(:action => 'edit', :id => shipping_method.id)
      else
        flash[:error] = I18n.t('shipping_method_detail.create.failed').capitalize
      end
    end
  end

  def edit_detail
    shipping_method = ShippingMethod.find_by_id(params[:id])
    @shipping_method_detail = shipping_method.shipping_method_details.find_by_id(params[:detail_id])
    if request.post?
      if @shipping_method_detail.update_attributes(params[:shipping_method_detail])
        flash[:notice] = I18n.t('shipping_method_detail.update.success').capitalize
      else
        flash[:error] = I18n.t('shipping_method_detail.update.failed').capitalize
      end
    end
  end

  def destroy_detail
    shipping_method = ShippingMethod.find_by_id(params[:id])
    @shipping_method_detail = shipping_method.shipping_method_details.find_by_id(params[:detail_id])
    if @shipping_method_detail.destroy
      flash[:notice] = I18n.t('shipping_method_detail.destroy.success').capitalize
      render :partial => 'list_details', :locals => { :shipping_method => shipping_method }
    end
  end

end
