class Admin::ProductsController < Admin::BaseController

  before_filter :get_product, :only => [:edit, :destroy, :show, :update, :activate, :duplicate]
  before_filter :new_product, :only => [:new, :create]
  before_filter :manage_tags, :only => [:create, :update]

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

  def duplicate
    @product = @product.clone
    render :action => 'new'
  end

  # Create a Product
  # ==== Params
  # * id = ProductParent's id
  # * product = Hash of Product's attributes
  def create
    if @product.save && manage_dynamic_attributes
      flash[:notice] = I18n.t('product.create.success').capitalize
      return redirect_to(admin_products_path)
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
      return redirect_to(admin_products_path)
    else
      flash[:error] = I18n.t('product.update.failed').capitalize
      render :action => 'edit'
    end
  end

  # Destroy a Product
  # ==== Params
  # * id = Product's id
  def destroy
    @deleted = @product.deleted? ? @product.destroy : @product.update_attribute(:deleted, true)
    
    if @deleted
      flash[:notice] = I18n.t('product.destroy.success').capitalize
      return redirect_to(admin_products_path) if !request.xhr?
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

  def update_attributes_list
    product_type = ProductType.find_by_id(params[:product_type_id])
    product = Product.find_by_id(params[:id])
    render :partial => 'attributes', :locals => { :product_type => product_type, :product => product }
  end

private
  
  # Called by :
  # <i>create_product</i>
  # <i>edit_product</i>
  # <i>quick_edit_product</i>
  # Update DynamicAttributes values
  # return false if one of update fail
  def manage_dynamic_attributes
    return true unless params[:dynamic_attribute_values]
    result = true
    @product.product_type.dynamic_attribute_ids.each do |d|
      if attribute_value = @product.dynamic_attribute_values.find_by_attribute_id(d)
        result = result & attribute_value.update_attributes(params[:dynamic_attribute_values][d.to_s])
      else
        if params[:dynamic_attribute_values][d.to_s]
          result = result & @product.dynamic_attribute_values.create(params[:dynamic_attribute_values][d.to_s].merge(:attribute_id => d))
        end
      end
    end
    return result
  end

  def manage_tags
    params[:product][:tag_list] = params[:tag_list].join(',')
  end

  def get_tag(name)
    return @tag = Tag.find_by_name(name) ? true : false
  end
  
  def get_product
    unless @product = Product.find_by_id(params[:id])
      flash[:error] = I18n.t('product.found.failed').capitalize
      return redirect_to(admin_products_path)
    end
    params[:product] = params[:pack] if params[:pack]
  end

  def new_product
    params[:product] = params[:pack] if params[:pack]
    @product = params[:type] == 'pack' ? Pack.new(params[:product]) : Product.new(params[:product])
  end

  def sort
    columns = %w(sku products.name price stock product_type_id active)
    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"

    conditions = {}
    includes = []
    options = { :page => page, :per_page => per_page }
    
    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :product_categories
    end
    conditions[:deleted] = params[:deleted] ? true : [false,nil]

    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      @products = Product.search(params[:sSearch],options)
    else
      @products = Product.paginate(:all,options)
    end
  end
end
