# This Controller Manage Categories
class Admin::CategoriesController < Admin::BaseController
  before_filter :get_category, :only => [:edit, :update, :destroy]
  before_filter :new_category, :only => [:new, :create]
  
  # List Categories like a Tree.
  def index
    @categories = Category.find_all_by_parent_id(nil)
  end

  def new
  end

  # Create a Category
  # ==== Params
  # * category = Hash of Category's attributes
  #
  # The Category can be a child of another Category.
  def create
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
    flash[:error] = I18n.t('category.not_exist').capitalize unless @category
  end
 
  def update
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
  # * id = Category's id
  # ==== Output
  #  if destroy succed, return the Categories list
  def destroy
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

  def add_element
    unless @category = Category.find_by_id_and_type(params[:id], params[:type])
      return flash[:error] = I18n.t('category.not_exist').capitalize
    end

    element_ids = @category.element_ids
    element_ids << params[:element_id].to_i
    element_ids.uniq!

    @category.update_attribute('element_ids', element_ids)
    return render :text => @category.total_elements_count
  end

private

  def get_category
    unless @category = Category.find_by_id(params[:id])
      flash[:error] = I18n.t('category.found.failed').capitalize
    end
  end

  def new_category
    @category = Category.new(params[:category])
  end
end
