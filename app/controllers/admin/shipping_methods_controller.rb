class Admin::ShippingMethodsController < Admin::BaseController
  def index
    @shipping_methods = ShippingMethod.all
  end

  def create
    @shipping_method = ShippingMethod.new(params[:shipping_method])
    if request.post?
      if @shipping_method.save
        flash[:notice] = 'Shipping Method was successfully created'
        redirect_to(:action => 'index')
      else
        flash[:error] = @shipping_method.errors
      end
    end
  end

  def edit
    @shipping_method = ShippingMethod.find_by_id(params[:id])
    if request.post?
      if @shipping_method.update_attributes(params[:shipping_method])
        flash[:notice] = 'Shipping Method was successfully updated'
      else
        flash[:error] = @shipping_method.errors
      end
    end
  end

  def show
    @shipping_method = ShippingMethod.find_by_id(params[:id])
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
        flash[:notice] = 'Shipping Method Detail was successfully created'
        redirect_to(:action => 'edit', :id => shipping_method.id)
      else
        flash[:error] = @shipping_method_detail.errors
      end
    end
  end

  def edit_detail
    shipping_method = ShippingMethod.find_by_id(params[:id])
    @shipping_method_detail = shipping_method.shipping_method_details.find_by_id(params[:detail_id])
    if request.post?
      if @shipping_method_detail.update_attributes(params[:shipping_method_detail])
        flash[:notice] = 'Shipping Method Detail was successfully created'
      else
        flash[:error] = @shipping_method_detail.errors
      end
    end
  end

  def destroy_detail
    shipping_method = ShippingMethod.find_by_id(params[:id])
    @shipping_method_detail = shipping_method.shipping_method_details.find_by_id(params[:detail_id])
    if @shipping_method_detail.destroy
      flash[:notice] = 'Shipping Method Detail was successfully destroyed'
      render :partial => 'list_details', :locals => { :shipping_method => shipping_method }
    end
  end

end
