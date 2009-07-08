class Admin::AttributesController < Admin::BaseController
  # List of AttributesGroup's Attributes 
  # ==== Params
  # * id = AttributesGroup's id
  def index
    @group = AttributesGroup.find_by_id(params[:attributes_group_id])
  end
  
  def new
    group = AttributesGroup.find_by_id(params[:attribute][:attributes_group_id])

    if group.dynamic
      flash[:warning] = I18n.t('attribute.create.dynamic').capitalize
      return redirect_to([:edit, :admin, group])
    end
    @attribute = group.tattributes.new(params[:attribute])
    render('create')
  end

  # Create a Attribute
  # ==== Params
  # * group_id = AttributesGroup's id
  # * attribute = Hash of Attribute's attributes
  def create
    group = AttributesGroup.find_by_id(params[:attributes_group_id])

    if group.dynamic
      flash[:warning] = I18n.t('attribute.create.dynamic').capitalize
      return redirect_to([:edit, :admin, group])
    end

    @attribute = group.tattributes.new(params[:attribute])
    if request.post?
      if @attribute.save
        flash[:notice] = I18n.t('attribute.create.success').capitalize
        redirect_to([:edit, :admin , group])
      else
        flash[:error] = I18n.t('attribute.create.failed').capitalize
      end
    end
  end

  # Edit a Attribute
  # ==== Params
  # * id = Attribute's id
  # * attribute = Hash of Attribute's attributes
  def edit
    @attribute = Attribute.find_by_id(params[:id])
  end

  def update
    @attribute = Attribute.find_by_id(params[:id])
    if @attribute.update_attributes(params[:attribute])
      flash[:notice] = I18n.t('attribute.update.success').capitalize
      return redirect_to([:edit, :admin, @attribute.attributes_group])
    else
      flash[:error] = I18n.t('attribute.update.failed').capitalize
    end
    render('edit')
  end

  # Destroy a Attribute
  # ==== Params
  # * id = Attribute's id
  def destroy
    @attribute = Attribute.find_by_id(params[:id])
    group = @attribute.attributes_group
    if @attribute.destroy
      flash[:notice] = I18n.t('attribute.destroy.success').capitalize
      render(:partial => 'list_attributes', :locals => { :group => group })
    else
      flash[:error] = I18n.t('attributes.destroy.failed').capitalize
    end
  end
end
