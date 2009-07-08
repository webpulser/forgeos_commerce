class Admin::ProductDetailsController < Admin::BaseController
  def index
    list
  end
  # Create a ProductDetail
  # ==== Params
  # * id = ProductParent's id
  # * product_detail = Hash of ProductDetail's attributes
  def create
    product_parent = ProductParent.find_by_id(params[:id])
    @product_detail = product_parent.product_details.new(params[:product_detail])
    if request.post?
      if @product_detail.save && manage_dynamic_attributes
        flash[:notice] = I18n.t('product_detail.create.success').capitalize
      else
        flash[:error] = I18n.t('product_detail.create.failed').capitalize
      end
    end
  end

  # Edit a ProductDetail
  # ==== Params
  # * id = ProductDetail's id
  # * product_detail = Hash of ProductDetail's attributes
  def edit
    @product_detail = Product.find_by_id(params[:id])
    return redirect_to(edit_admin_product_path(@product_detail)) if @product_detail.is_a?(ProductParent)
  end

  def update
    @product_detail = Product.find_by_id(params[:id])
    if @product_detail.update_attributes(params[:product_detail]) && manage_dynamic_attributes
      flash[:notice] = I18n.t('product_detail.update.success').capitalize
    else
      flash[:error] = I18n.t('product_detail.update.failed').capitalize
    end
    redirect_to([:edit, :admin, @product_detail.product_parent])
  end

  # Edit quickly and remotely a ProductDetail
  # ==== Params
  # * id = ProductDetail's id
  # * product_detail = Hash of ProductDetail's attributes
  def quick_edit
    @product_detail = ProductDetail.find_by_id(params[:id])
    if request.post?
      if @product_detail.update_attributes(params[:product_detail]) && manage_dynamic_attributes
        flash[:notice] = I18n.t('product_detail.update.success').capitalize
        #return (render :update do |page|
        #  page.replace_html 'list', :partial => 'list_product_details', :locals => { :product_parent => @product_detail.product_parent }
        #end)
      else
        flash[:error] = I18n.t('product_detail.update.failed').capitalize
      end
    end
    if request.xhr?
      return (render :update do |page|
        page.replace_html 'quick_edit', :partial => 'quick_form', :locals => { :product_detail => @product_detail }
      end)
    else
      return redirect_to(:action => 'edit', :id => @product_detail.product_id )
    end
  end

  # Destroy a ProductDetail
  # ==== Params
  # * id = ProductDetail's id
  def destroy
    @product_detail = ProductDetail.find_by_id(params[:id])
    product_parent = @product_detail.product_parent
    unless @product_detail.deleted?
      @success = @product_detail.soft_delete
    else
      @success = @product_detail.destroy
    end
    if @success
      flash[:notice] = I18n.t('product_detail.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product_detail.destroy.failed').capitalize
    end
    return render(:partial => 'list', :locals => { :product_details => product_parent.product_details.find_all_by_deleted(false) })
  end

  def list
    @product_parent = ProductParent.find_by_id(params[:id])
    render :partial => 'list', :locals => { :product_details => @product_parent.product_details.find_all_by_deleted(true) }
  end

protected
  
  # Called by :
  # <i>create_product_detail</i>
  # <i>edit_product_detail</i>
  # <i>quick_edit_product_detail</i>
  # Update DynamicAttributes values
  # return false if one of update fail
  def manage_dynamic_attributes
    return true unless params[:dynamic_attributes]
    result = true
    @product_detail.dynamic_attributes.each do |d|
      result = result & d.update_attributes(params[:dynamic_attributes][d.attributes_group_id.to_s])
    end
    return result
  end
end
