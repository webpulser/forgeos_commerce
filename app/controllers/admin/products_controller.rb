class Admin::ProductsController < Admin::BaseController
  before_filter :get_product, :only => [:edit, :destroy, :show, :update, :activate]
  before_filter :new_product, :only => [:new, :create]

  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  def new
  end

  # Create a Product
  # ==== Params
  # * id = ProductParent's id
  # * product = Hash of Product's attributes
  def create
    if @product.save && manage_dynamic_attributes
      flash[:notice] = I18n.t('product.create.success').capitalize
      redirect_to(admin_products_path)
    else
      flash[:error] = I18n.t('product.create.failed').capitalize
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update_attributes(params[:product]) && manage_dynamic_attributes
      flash[:notice] = I18n.t('product.update.success').capitalize
      redirect_to(admin_products_path)
    else
      flash[:error] = I18n.t('product.update.failed').capitalize
      render :edit
    end
  end

  # Destroy a Product
  # ==== Params
  # * id = Product's id
  def destroy
    @deleted = @product.deleted? ? @product.destroy : @product.update_attribute(:deleted, true)
    
    if @deleted
      flash[:notice] = I18n.t('product.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product.destroy.failed').capitalize
    end
    render :nothing => true
  end

  def url
    render :text => Forgeos::url_generator(params[:url])
  end

  def activate
    render :text => @product.activate
  end

private
  
  # Called by :
  # <i>create_product</i>
  # <i>edit_product</i>
  # <i>quick_edit_product</i>
  # Update DynamicAttributes values
  # return false if one of update fail
  def manage_dynamic_attributes
    return true unless params[:dynamic_tattribute_values]
    result = true
    @product.dynamic_tattribute_values.each do |d|
      result = result & d.update_attributes(params[:dynamic_tattribute_values][d.tattribute_id.to_s])
    end
    return result
  end
  
  def get_product
    unless @product = Product.find_by_id(params[:id])
      flash[:error] = I18n.t('product.found.failed').capitalize
      redirect_to(admin_products_path)
    end
  end

  def new_product
    @product = Product.new(params[:product])
  end

  def sort
    columns = %w(reference name description price stock active)
    conditions = []
    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
    if params[:sSearch] && !params[:sSearch].blank?
      @products = Product.search(params[:sSearch],
        :order => order,
        :page => page,
        :per_page => per_page)
    else
      @products = Product.paginate(:all,
        :conditions => conditions,
        :order => order,
        :page => page,
        :per_page => per_page)
    end
  end
end
