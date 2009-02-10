# This Controller Manage Categories
class Admin::CategoriesController < Admin::BaseController
  # List Categories like a Tree.
  def index
    @categories = Category.find_all_by_parent_id(nil)
  end

  def new
    @category = Category.new(params[:category])
    render :action => 'create'
  end
  # Create a Category
  # ==== Params
  # * category = Hash of Category's attributes
  #
  # The Category can be a child of another Category.
  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = 'The Category was successfully created'
      redirect_to(edit_admin_category_path @category )
    else
      flash[:error] = @category.errors
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
  end
 
  def update
    @category = Category.find_by_id(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = 'The Category was successfully saved'
    else
      flash[:error] = @category.errors
    end
    render :action => 'edit'
  end
  # Destroy a Category
  # ==== Params
  # * id = ProductCategory's id
  # ==== Output
  #  if destroy succed, return the Categories list
  def destroy
    @category = Category.find_by_id(params[:id])
    if @category.destroy
      flash[:notice] = 'The Category was successfully destroyed'
      index
      return render(:partial => 'list', :locals => { :categories => @categories })
    else
      flash[:error] = @category.errors
    end
  end

end
