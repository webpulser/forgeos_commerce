class Admin::ProductsController < Admin::BaseController
  before_filter :get_product, :except => [:index, :new, :create, :url]
  before_filter :new_product, :only => [:new, :create]

  def index
    @products = Product.all(:conditions => { :deleted => !params[:deleted].nil? })
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
    return render(:partial => 'list', :locals => { :products => Product.all })
  end

  def url
    render :text => Forgeos::url_generator(params[:url])
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
end
