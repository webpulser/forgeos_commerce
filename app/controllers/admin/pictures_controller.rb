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
    respond_to do |format|
      format.html do
        @picture = Picture.new(params[:picture])
        if @picture.save
          sortable_picture = @picture.sortable_attachments.new
          flash[:notice] = I18n.t('picture.create.success').capitalize
          case params[:target]
          when 'product'
            picturable = Product.find_by_id(params[:target_id])
          when 'product_type'
            picturable = ProductType.find_by_id(params[:target_id])
          when 'tattribute'
            picturable = Tattribute.find_by_id(params[:target_id])
          when 'tattribute_value'
            picturable = TattributeValue.find_by_id(params[:target_id])
          when 'category'
            picturable = Category.find_by_id(params[:target_id])
          else
            return redirect_to(:action => 'index')
          end
          sortable_picture.attachable = picturable
          sortable_picture.save
          return redirect_to([:edit, :admin, picturable])

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
            sortable_picture = @picture.sortable_attachments.new
            flash[:notice] = I18n.t('picture.create.success').capitalize
            case params[:target]
            when 'product'
              sortable_picture.attachable = Product.find_by_id(params[:target_id])
            when 'product_type'
              sortable_picture.attachable = ProductType.find_by_id(params[:target_id])
            when 'tattribute'
              sortable_picture.attachable = Tattribute.find_by_id(params[:target_id])
            when 'tattribute_value'
              sortable_picture.attachable = TattributeValue.find_by_id(params[:target_id])
            when 'category'
              sortable_picture.attachable = Category.find_by_id(params[:target_id])
            end
            sortable_picture.save if sortable_picture.attachable
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
      picturable = Product.find_by_id(params[:target_id])
    when 'product_type'
      picturable = ProductType.find_by_id(params[:target_id])
    when 'tattribute'
      picturable = Tattribute.find_by_id(params[:target_id])
    when 'tattribute_value'
      picturable = TattributeValue.find_by_id(params[:target_id])
    when 'category'
      picturable = Category.find_by_id(params[:target_id])
    else
      index
    end
    
    @pictures = picturable.attachments.find_all_by_type('Picture') if picturable

    if @success
      flash[:notice] = I18n.t('picture.destroy.success').capitalize
      return render(:update) do |page|
        if params[:target].blank?
          page << "oTable.fnDeleteRow(oTable.fnGetPosition($('#tags_for_#{params[:id]}').parents('tr')[0]));"
        else
          page << "$('#tags_for_#{params[:id]}').parents('tr').remove()"
        end
        page << display_standard_flashes('',false)
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
      when 'product_type'
        @target = ProductType.find_by_id(params[:id])
      when 'tattribute'
        @target = Tattribute.find_by_id(params[:id])
      when 'tattribute_value'
        @target = TattributeValue.find_by_id(params[:id])
      when 'category'
        @target = Category.find_by_id(params[:id])
      else
        return render(:nothing => true)
      end
      pictures = @target.sortable_attachments
      pictures.each do |picture|
        if index = params['picture_list'].index(picture.attachment_id.to_s)
          picture.update_attribute(:position, index+1)
        end
      end
    end
    render(:nothing => true)
  end
end
