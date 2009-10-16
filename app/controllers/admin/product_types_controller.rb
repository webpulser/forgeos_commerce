# This Controller Manage Products and his association with
# ProductDetail
class Admin::ProductTypesController < Admin::BaseController
  # List ProductType
  before_filter :get_product_type, :only => [:show, :edit, :update, :destroy]
  before_filter :new_product_type, :only => [:new, :create]
  
  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  def show
  end

  def new
  end

  # Create a ProductType
  # ==== Params
  # * product_type = Hash of ProductType's attributes
  def create
    if @product_type.save
      flash[:notice] = I18n.t('product_type.create.success').capitalize
      return redirect_to(admin_product_types_path)
    else
      flash[:error] = I18n.t('product_type.create.failed').capitalize
      render :action => :new
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
      return redirect_to(admin_product_types_path)
    else
      flash[:error] = I18n.t('product.update.failed').capitalize
      render :action => 'edit'
    end
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
    return redirect_to(admin_product_types_path)
  end

private
  def get_product_type
    unless @product_type = ProductType.find_by_id(params[:id])
      flash[:error] = I18n.t('product_type.found.failed').capitalize
      return redirect_to(admin_product_types_path)
    end
  end

  def new_product_type
    @product_type = ProductType.new(params[:product_type])
  end
  
  def sort
    columns = %w(product_types.name product_types.name count(products.id) product_types.name)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
 
    conditions = {}
    options = { :page => page, :per_page => per_page }

    includes = []
    includes << :products if params[:iSortCol_0].to_i == 2

    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :product_type_categories
    end
   
    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      @product_types = ProductType.search(params[:sSearch],options)
    else
      @product_types = ProductType.paginate(:all,options)
    end
  end
end
