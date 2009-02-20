# This Controller Manage Products and his association with
# ProductDetail
class Admin::ProductsController < Admin::BaseController
  # List ProductParent
  def index
    @products = ProductParent.all
  end

  def new
    @product_parent = ProductParent.new(params[:product_parent])
    @product_parent.rate_tax = 19.6
    render :action => 'create'
  end

  # Create a ProductParent
  # ==== Params
  # * product_parent = Hash of ProductParent's attributes
  def create
    @product_parent = ProductParent.new(params[:product_parent])
    if @product_parent.save
      flash[:notice] = I18n.t('product.create.success').capitalize
      redirect_to edit_admin_product_path(:id => @product_parent.id)
    else
      flash[:error] = I18n.t('product.create.failed').capitalize
    end
  end
  
  def edit
    @product_parent = Product.find_by_id(params[:id])
    return redirect_to(:action => 'edit_product_detail', :id => params[:id]) if @product_parent.is_a?(ProductDetail)
  end

  # Update a ProductParent
  # ==== Params
  # * id = ProductParent's id
  def update
    @product_parent = Product.find_by_id(params[:id])
    if @product_parent.update_attributes(params[:product_parent])
      flash[:notice] = I18n.t('product.update.success').capitalize
    else
      flash[:error] = I18n.t('product.update.failed').capitalize
    end
    render :action => 'edit'
  end

  # Destroy a ProductParent
  # ==== Params
  # * id = ProductParent's id
  def destroy
    @product_parent = ProductParent.find_by_id(params[:id])
    if @product_parent.destroy
      flash[:notice] = I18n.t('product.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product.destroy.failed').capitalize
    end
    return redirect_to(:action => 'index' )
  end

  # Create a ProductDetail
  # ==== Params
  # * id = ProductParent's id
  # * product_detail = Hash of ProductDetail's attributes
  def create_product_detail
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
  def edit_product_detail
    @product_detail = Product.find_by_id(params[:id])
    return redirect_to(:action => 'edit', :id => params[:id]) if @product_detail.is_a?(ProductParent)
    if request.post?
      if @product_detail.update_attributes(params[:product_detail]) && manage_dynamic_attributes
        flash[:notice] = I18n.t('product_detail.update.success').capitalize
      else
        flash[:error] = I18n.t('product_detail.update.failed').capitalize
      end
    end
  end

  # Edit quickly and remotely a ProductDetail
  # ==== Params
  # * id = ProductDetail's id
  # * product_detail = Hash of ProductDetail's attributes
  def quick_edit_product_detail
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
        page.replace_html 'quick_edit', :partial => 'quick_form_product_detail', :locals => { :product_detail => @product_detail }
      end)
    else
      return redirect_to(:action => 'edit', :id => @product_detail.product_id )
    end
  end

  # Destroy a ProductDetail
  # ==== Params
  # * id = ProductDetail's id
  def destroy_product_detail
    @product_detail = ProductDetail.find_by_id(params[:id])
    product_parent = @product_detail.product_parent
    if @product_detail.destroy
      flash[:notice] = I18n.t('product_detail.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product_detail.destroy.failed').capitalize
    end
    return render(:partial => 'list_product_details', :locals => { :product_parent => product_parent })
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
