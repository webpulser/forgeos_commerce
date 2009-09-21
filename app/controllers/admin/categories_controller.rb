# This Controller Manage Categories
class Admin::CategoriesController < Admin::BaseController
  before_filter :get_category, :only => [:edit, :update, :destroy, :add_element]
  before_filter :new_category, :only => [:new, :create]
  skip_before_filter :login_required, :only => [:index]
  skip_before_filter :set_currency, :only => [:index]
  
  # List Categories like a Tree.
  def index
    klass = params[:type].camelize.constantize
    @categories = klass.find_all_by_parent_id(nil)
    respond_to do |format|
      format.json{ render :json => @categories.collect(&:to_jstree).to_json }
    end
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
  end
 
  def update
    if @category.update_attributes(params[:category])
      flash[:notice] = I18n.t('category.update.success').capitalize
    else
      flash[:error] = I18n.t('category.update.failed').capitalize
    end

    respond_to do |format|
      format.html { render :action => 'edit' }
      format.json { render :text => @category.total_elements_count }
    end
  end

  # Destroy a Category
  # ==== Params
  # * id = Category's id
  # ==== Output
  #  if destroy succed, return the Categories list
  def destroy
    if @category.destroy
      flash[:notice] = I18n.t('category.destroy.success').capitalize
    else
      flash[:error] = I18n.t('category.destroy.failed').capitalize
    end
    render :text => true
  end

  def add_element
    render :text => @category.update_attribute(:element_ids, @category.element_ids << params[:element_id].to_i)
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
