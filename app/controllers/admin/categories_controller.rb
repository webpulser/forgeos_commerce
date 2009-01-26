# This Controller Manage Categories
class Admin::CategoriesController < Admin::BaseController
  # List Categories like a Tree.
  def index
    @categories = Category.find_all_by_parent_id(nil)
  end

  # Create a Category
  # ==== Params
  # * category = Hash of Category's attributes
  #
  # The Category can be a child of another Category.
  def create
    @category = Category.new(params[:category])
    if request.post?
      if @category.save
        flash[:notice] = 'The Category was successfully created'
      else
        flash[:error] = @category.errors
      end
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
    if request.post?
      if @category.update_attributes(params[:category])
        flash[:notice] = 'The Category was successfully saved'
      else
        flash[:error] = @category.errors
      end
    end
  end
 
  # Destroy a Category
  # ==== Params
  # * id = ProductCategory's id
  # ==== Output
  #  if destroy succed, return the Categories list
  def destroy
    @category = Category.find_by_id(params[:id])
    if request.post?
      if @category.destroy
        flash[:notice] = 'The Category was successfully destroyed'
        index
        return render(:partial => 'list', :locals => { :categories => @categories })
      else
        flash[:error] = @category.errors
      end
    end
  end

end
