class Admin::ProductsController < Admin::BaseController
  before_filter :get_product, :except => [:index, :new, :create, :url]
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

  def url
    render :text => url_generator(params[:url])
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

  def url_generator(phrase = '')
    url = phrase.dup
    { %w(á à â ä ã Ã Ä Â À) => 'a',
      %w(é è ê ë Ë É È Ê €) => 'e',
      %w(í ì î ï I Î Ì) => 'i',
      %w(ó ò ô ö õ Õ Ö Ô Ò) => 'o',
      %w(œ) => 'oe',
      %w(ß) => 'ss',
      %w(ú ù û ü U Û Ù) => 'u',
      %w(\/ \| \\ \\& = #) => '',
      %w(\s+) => '_'
    }.each do |ac,rep|
      url.gsub!(Regexp.new(ac.join('|')), rep)
    end

    url.underscore.gsub(/(^_+|_+$)/,'')
  end
end
