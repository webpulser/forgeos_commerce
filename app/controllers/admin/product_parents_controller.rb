# This Controller Manage Products and his association with
# ProductDetail
class Admin::ProductParentsController < Admin::BaseController
  # List ProductParent
  def index
    @products = ProductParent.all(:conditions => { :deleted => !params[:deleted].nil? })
  end

  def activate
    @product = Product.find_by_id(params[:id])
    render :text => @product.activate
  end

  def new
    @product_parent = ProductParent.new(params[:product_parent])
    @product_parent.rate_tax = 0.0
    render :action => 'create'
  end

  # Create a ProductParent
  # ==== Params
  # * product_parent = Hash of ProductParent's attributes
  def create
    @product_parent = ProductParent.new(params[:product_parent])
    if @product_parent.save
      flash[:notice] = I18n.t('product.create.success').capitalize
      return redirect_to(edit_admin_product_parent_path(@product_parent))
    else
      flash[:error] = I18n.t('product.create.failed').capitalize
    end
  end
  
  def edit
    @product_parent = Product.find_by_id(params[:id])
    return redirect_to(edit_admin_product_detail_path(@product_parent)) if @product_parent.is_a?(ProductDetail)
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
    unless @product_parent.deleted?
      @success = @product_parent.soft_delete
    else
      @success = @product_parent.destroy
    end

    if @success
      flash[:notice] = I18n.t('product.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product.destroy.failed').capitalize
    end
    return redirect_to(:action => 'index' )
  end

end
