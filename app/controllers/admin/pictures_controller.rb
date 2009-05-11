# This Controller Manage Pictures and there associations with
#  * Product
#  * AttributesGroup
#  * Attribute
#  * Category
#  * Comment
class Admin::PicturesController < Admin::BaseController
  session :cookie_only => false, :only => :create
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
    respond_to do |format|
      format.html do
        @picture = Picture.new(params[:picture])
        if @picture.save
          sortable_picture = @picture.sortable_pictures.new
          flash[:notice] = I18n.t('picture.create.success').capitalize
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
          flash[:error] = I18n.t('picture.create.failed').capitalize
        end
      end

      format.json do
        if params[:Filedata]
          require 'mime/types'
          @picture = Picture.new
          @picture.uploaded_data = { 'tempfile' => params[:Filedata], 'content_type' => 'none', 'filename' => params[:Filename] }
          @picture.content_type = MIME::Types.type_for(@picture.filename).to_s
          if @picture.save
            sortable_picture = @picture.sortable_pictures.new
            flash[:notice] = I18n.t('picture.create.success').capitalize
            case params[:target]
            when 'product'
              sortable_picture.picturable = Product.find_by_id(params[:target_id])
              sortable_picture.save
            when 'attributes_group'
              sortable_picture.picturable = AttributesGroup.find_by_id(params[:target_id])
              sortable_picture.save
            when 'tattribute'
              sortable_picture.picturable = Attribute.find_by_id(params[:target_id])
              sortable_picture.save
            when 'category'
              sortable_picture.picturable = Category.find_by_id(params[:target_id])
              sortable_picture.save
            end
            render :json => { :result => 'success', :asset => @picture.id}
          else
            logger.debug(@picture.errors.inspect)
            render :json => { :result => 'error', :error => @picture.errors.first }
          end
        else
          render :json => { :result => 'error', :error => 'bad parameters' }
        end
      end
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
      flash[:notice] = I18n.t('picture.destroy.success').capitalize
      return render(:update) do |page|
        if params[:target].blank?
          page << "oTable.fnDeleteRow(oTable.fnGetPosition($('#tags_for_#{params[:id]}').parents('tr')[0]));"
        else
          page << "$('#tags_for_#{params[:id]}').parents('li').remove()"
        end
      end if request.xhr?
      return render(:partial => 'list', :locals => { :pictures => @pictures, :target => params[:target], :target_id => params[:target_id] })
    else
      flash[:error] = I18n.t('picture.destroy.failed').capitalize
    end
  end

  # Create a Picture's comment 
  # and render his comments list
  def create_comment
    @picture = Picture.find_by_id(params[:id])
    @comment = @picture.comments.new(params[:comment])
    @comment.user = current_user
    if request.post?
      if @comment.save
        flash[:notice] = I18n.t('comment.create.success').capitalize
        return render(:partial => 'list_comments', :locals => { :comments => @picture.comments })
      else
        flash[:error] = I18n.t('comment.create.failed').capitalize
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
      flash[:notice] = I18n.t('comment.destroy.success').capitalize
      return render(:partial => 'list_comments', :locals => { :comments => @picture.comments })
    else
      flash[:error] = I18n.t('comment.destroy.failed').capitalize
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
        if index = params['picture_list'].index(picture.picture_id.to_s)
          picture.update_attribute(:position,index+1)
        end
      end
    end
    render(:nothing => true)
  end

end
