class Admin::ProductsController < Admin::BaseController
  before_filter :get_product, :except => [:index, :new, :create]
  before_filter :new_product, :only => [:new, :create]

  def index
    @products = Product.all(:conditions => { :deleted => !params[:deleted].nil? })
  end

  def new
    render :create
  end

  # Create a Product
  # ==== Params
  # * id = ProductParent's id
  # * product = Hash of Product's attributes
  def create
    if @product.save && manage_dynamic_attributes
      flash[:notice] = I18n.t('product.create.success').capitalize
      redirect_to([:edit, :admin, @product])
    else
      flash[:error] = I18n.t('product.create.failed').capitalize
    end
  end

  def edit
  end

  def update
    if @product.update_attributes(params[:product]) && manage_dynamic_attributes
      flash[:notice] = I18n.t('product.update.success').capitalize
    else
      flash[:error] = I18n.t('product.update.failed').capitalize
    end
    redirect_to([:edit, :admin, @product])
  end

  # Edit quickly and remotely a Product
  # ==== Params
  # * id = Product's id
  # * product = Hash of Product's attributes
  def quick_edit
    if request.post?
      if @product.update_attributes(params[:product]) && manage_dynamic_attributes
        flash[:notice] = I18n.t('product.update.success').capitalize
        #return (render :update do |page|
        #  page.replace_html 'list', :partial => 'list_products', :locals => { :product_parent => @product.product_parent }
        #end)
      else
        flash[:error] = I18n.t('product.update.failed').capitalize
      end
    end
    if request.xhr?
      return (render :update do |page|
        page.replace_html 'quick_edit', :partial => 'quick_form', :locals => { :product => @product }
      end)
    else
      return redirect_to([:edit, :admin, @product])
    end
  end

  # Destroy a Product
  # ==== Params
  # * id = Product's id
  def destroy
    @deleted = case
               when @product.deleted? then @product.destroy
               else @product.update_attribute(:deleted, true)
               end
    if @deleted
      flash[:notice] = I18n.t('product.destroy.success').capitalize
    else
      flash[:error] = I18n.t('product.destroy.failed').capitalize
    end
    return render(:partial => 'list', :locals => { :products => Product.all })
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
      redirect_to([:admin, :root])
    end
  end

  def new_product
    @product = Product.new(params[:product])
  end
end
