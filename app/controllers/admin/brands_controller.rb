class Admin::BrandsController < Admin::BaseController

  before_filter :get_brand, :only => [:edit, :update, :destroy]
  before_filter :new_brand, :only => [:new, :create]

  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end
#  def show
#  end

  def new
    @brand.comments.build if @brand.comments.empty?
  end

  # Create a Brand
  # ==== Params
  # * brand = Hash of Brand's attributes
  def create
    if @brand.save
      flash[:notice] = I18n.t('brand.create.success').capitalize
      redirect_to([forgeos_commerce, :admin, :brands])
    else
      flash[:error] = I18n.t('brand.create.failed').capitalize
      render :action => :new
    end
  end

  def edit
    @brand.comments.build if @brand.comments.empty?
  end

  # Update a Brand
  # ==== Params
  # * id = Brand's id
  def update
    if @brand.update_attributes(params[:brand])
      flash[:notice] = I18n.t('brand.update.success').capitalize
      redirect_to :action => 'edit'
    else
      flash[:error] = I18n.t('brand.update.failed').capitalize
      render :action => 'edit'
    end
  end

  # Destroy a Brand
  # ==== Params
  # * id = Brand's id
  def destroy
    if @brand.destroy
      flash[:notice] = I18n.t('brand.destroy.success').capitalize
    else
      flash[:error] = I18n.t('brand.destroy.failed').capitalize
    end
    respond_to do |wants|
      wants.html do
        redirect_to([forgeos_commerce, :admin, :brands])
      end
      wants.js
    end
  end

  def url
    render :text => Forgeos::url_generator(params[:url])
  end

  private


  def get_brand
    unless @brand = Brand.find_by_id(params[:id])
      flash[:error] = I18n.t('brand.found.failed').capitalize
      return redirect_to[forgeos_commerce, :admin, :brands])
    end
  end

  def new_brand
    @brand = Brand.new(params[:brand])
  end


  def sort
    columns = %w(brands.name brands.name)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:sSortDir_0].upcase}"

    conditions = {}
    options = { :page => page, :per_page => per_page }

    includes = []
    includes << :products if params[:iSortCol_0].to_i == 2

    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :categories
    end

    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @brands = Brand.search(params[:sSearch],options)
    else
      @brands = Brand.paginate(options)
    end
  end

end
