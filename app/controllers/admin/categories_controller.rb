# This Controller Manage Categories
class Admin::CategoriesController < Admin::BaseController
  # List Categories like a Tree.
  def index
    @categories = Category.find_all_by_parent_id(nil)
  end

  def new
    @category = Category.new
  end
  # Create a Category
  # ==== Params
  # * category = Hash of Category's attributes
  #
  # The Category can be a child of another Category.
  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = I18n.t('category.create.success').capitalize
      respond_to do |format|
        format.html { redirect_to([:edit, :admin, @category]) }
        format.json { render :text => @category.id }
      end
    else
      flash[:error] = I18n.t('category.create.failed').capitalize
      render :action => 'new'
    end
  end

  # Edit a Category
  # ==== Params
  # * id = Category's id to edit
  # * category = Hash of Category's attributes
  #
  # The Category can be a child of another Category.
  def edit
    @category = Category.find_by_id(params[:id])
    flash[:error] = I18n.t('category.not_exist').capitalize unless @category
  end
 
  def update
    @category = Category.find_by_id(params[:id])
    if @category && request.put?
      if @category.update_attributes(params[:category])
        flash[:notice] = I18n.t('category.update.success').capitalize
      else
        flash[:error] = I18n.t('category.update.failed').capitalize
      end

      respond_to do |format|
        format.html { render :action => 'edit' }
        #format.json { render :text => @category.id }
        format.json { render :text => @category.total_elements_count }
      end
    else
      flash[:error] = I18n.t('category.not_exist').capitalize
      redirect_to admin_categories_path
    end
  end
  # Destroy a Category
  # ==== Params
  # * id = ProductCategory's id
  # ==== Output
  #  if destroy succed, return the Categories list
  def destroy
    @category = Category.find_by_id(params[:id])
    if @category && request.delete?
      if @category.destroy
        flash[:notice] = I18n.t('category.destroy.success').capitalize
      else
        flash[:error] = I18n.t('category.destroy.failed').capitalize
      end
    else
      flash[:error] = I18n.t('category.not_exist').capitalize
    end
    render(:update) do |page|
      display_standard_flashes
    end
  end

end
