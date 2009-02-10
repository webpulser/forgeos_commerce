# This Controller Manage Pictures and there associations with
#  * Product
#  * AttributesGroup
#  * Attribute
#  * Category
#  * Comment
class Admin::PicturesController < Admin::BaseController
  # List all pictures
  def index
    @pictures = Picture.find(:all, :conditions => 'parent_id IS NULL')
  end

  # Show Picture details
  def show
    @picture = Picture.find_by_id(params[:id])
  end

  def new
    @picture = Picture.new(params[:picture])
    render :action => 'create'
  end

  # Create a Picture
  # and redirect to
  # his owner edit page or pictures/index page
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save
      sortable_picture = @picture.sortable_pictures.new
      flash[:notice] = 'The Picture was successfully created'
      case params[:target]
      when 'product'
        sortable_picture.picturable = Product.find_by_id(params[:target_id])
        sortable_picture.save
        return redirect_to(:controller => 'products', :action => 'edit', :id => params[:target_id])
      when 'attributes_group'
        sortable_picture.picturable = AttributesGroup.find_by_id(params[:target_id])
        sortable_picture.save
       return redirect_to(:controller => 'attributes_groups', :action => 'edit', :id => params[:target_id])
      when 'tattribute'
        sortable_picture.picturable = Attribute.find_by_id(params[:target_id])
        sortable_picture.save
       return redirect_to(:controller => 'attributes_groups', :action => 'edit_attribute', :id => params[:target_id])
      when 'category'
        sortable_picture.picturable = Category.find_by_id(params[:target_id])
        sortable_picture.save
        return redirect_to(:controller => 'categories', :action => 'edit', :id => params[:target_id])
      else
        return redirect_to(:action => 'index')
      end
    else
      flash[:error] = @picture.errors
    end
  end

  # Destroy a Picture 
  # and render
  # his owner picture list or pictures/index list
  def destroy
    @picture = Picture.find_by_id(params[:id])
    @success = @picture.destroy
    case params[:target]
    when 'product'
      product = Product.find_by_id(params[:target_id])
      @pictures = product.pictures
    when 'attributes_group'
      attributes_group = AttributesGroup.find_by_id(params[:target_id])
      @pictures = attributes_group.pictures
    when 'tattribute'
      tattribute = Attribute.find_by_id(params[:target_id])
      @pictures = tattribute.pictures
    when 'category'
      category = Category.find_by_id(params[:target_id])
      @pictures = category.pictures
    else
      index
    end

    if @success
      flash[:notice] = 'The Picture was successfully destroyed'
      return render(:partial => 'list', :locals => { :pictures => @pictures, :target => params[:target], :target_id => params[:target_id] })
    else
      flash[:error] = @picture.errors
    end
  end

  # Create a Picture's comment 
  # and render his comments list
  def create_comment
    @picture = Picture.find_by_id(params[:id])
    @comment = @picture.comments.new(params[:comment])
    if request.post?
      if @comment.save
        flash[:notice] = 'The Comment was successfully created'
        return render(:partial => 'list_comments', :locals => { :comments => @picture.comments })
      else
        flash[:error] = @comment.errors
      end
    end
    render(:partial => 'form_comment', :locals => { :comment => @comment })
  end

  # Destroy a Picture's comment
  # and render his comments list
  def destroy_comment
    @picture = Picture.find_by_id(params[:id])
    @comment = @picture.comments.find_by_id(params[:comment_id])
    if @comment.destroy
      flash[:notice] = 'The Comment was successfully destroyed'
      return render(:partial => 'list_comments', :locals => { :comments => @picture.comments })
    else
      flash[:error] = @comment.errors
    end
  end

  # Sort Picture for
  # * Product
  # * Category
  # * Attribute
  # * AttributesGroup
  def sort
    if params['picture_list']
      case params[:target]
      when 'product'
        @target = Product.find_by_id(params[:id])
        pictures = @target.sortable_pictures
      when 'tattribute'
        @target = Attribute.find_by_id(params[:id])
        pictures = @target.sortable_pictures
      when 'attributes_group'
        @target = AttributesGroup.find_by_id(params[:id])
        pictures = @target.sortable_pictures
      when 'category'
        @target = Category.find_by_id(params[:id])
        pictures = @target.sortable_pictures
      else
        return render(:nothing => true)
      end

      pictures.each do |picture|
        picture.update_attribute(:position,params['picture_list'].index(picture.picture_id.to_s)+1)
      end
    end
    render(:nothing => true)
  end

end
