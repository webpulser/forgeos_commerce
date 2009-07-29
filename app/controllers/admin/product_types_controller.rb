# This Controller Manage Products and his association with
# ProductDetail
class Admin::ProductTypesController < Admin::BaseController
  # List ProductType
  before_filter :get_product_type, :except => [:index, :new, :create]
  before_filter :new_product_type, :only => [:new, :create]
  def index
    @product_types = ProductType.all
  end

  def new
    render :create
  end

  # Create a ProductType
  # ==== Params
  # * product_type = Hash of ProductType's attributes
  def create
    if @product_type.save
      flash[:notice] = I18n.t('product_type.create.success').capitalize
      return redirect_to(edit_admin_product_type_path(@product_type))
    else
      flash[:error] = I18n.t('product_type.create.failed').capitalize
    end
  end
  
  def edit
  end

  # Update a ProductType
  # ==== Params
  # * id = ProductType's id
  def update
    if @product_type.update_attributes(params[:product_type])
      flash[:notice] = I18n.t('product.update.success').capitalize
    else
      flash[:error] = I18n.t('product.update.failed').capitalize
    end
    render :action => 'edit'
  end

  # Destroy a ProductType
  # ==== Params
  # * id = ProductType's id
  def destroy
    if @product_type.destroy
      flash[:notice] = I18n.t('product.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product.destroy.failed').capitalize
    end
    return redirect_to(:action => 'index' )
  end

private
  def get_product_type
    unless @product_type = ProductType.find_by_id(params[:id])
      flash[:error] = I18n.t('product_type.found.failed').capitalize
      redirect_to([:admin, :root])
    end
  end

  def new_product_type
    @product_type = ProductType.new(params[:product_type])
  end
end