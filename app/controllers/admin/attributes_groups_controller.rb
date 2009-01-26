# This Controller Manage AttributesGroups and his association with
# Attributes
class Admin::AttributesGroupsController < Admin::BaseController
  # List AttributesGroup
  def index
    @groups = AttributesGroup.all
  end

  # Create a AttributesGroup
  # ==== Params
  # * attributes_group = Hash of AttributesGroup's attributes
  def create
    @attributes_group = AttributesGroup.new(params[:attributes_group])
    if request.post?
      if @attributes_group.save
        flash[:notice] = 'Attributes Group was successfully saved'
      else
        flash[:error] = 'A problem occured during Attributes Group save'
      end
    end
  end

  # Edit a AttributesGroup
  # ==== Params
  # * id = AttributesGroup's id
  def edit
    @attributes_group = AttributesGroup.find_by_id(params[:id])
    if request.post?
      if @attributes_group.update_attributes(params[:attributes_group])
        flash[:notice] = 'Attributes Group was successfully saved'
      else
        flash[:error] = 'A problem occured during Attributes Group save'
      end
    end
  end

  # Destroy a AttributesGroup
  # ==== Params
  # * id = AttributesGroup's id
  def destroy
    @group = AttributesGroup.find_by_id(params[:id])
    if @group.destroy
      flash[:notice] = 'Attributes Group was successfully destroyed'
    else
      flash[:error] = 'A problem occured during Attributes Group destroy'
    end
    return redirect_to(:action => 'index')
  end

  # List of AttributesGroup's Attributes 
  # ==== Params
  # * id = AttributesGroup's id
  def list_attributes
    @group = AttributesGroup.find_by_id(params[:id])
  end

  # Create a Attribute
  # ==== Params
  # * group_id = AttributesGroup's id
  # * attribute = Hash of Attribute's attributes
  def create_attribute
    group = AttributesGroup.find_by_id(params[:group_id])

    if group.dynamic
      flash[:warning] = "This group is dynamic, it can't have attributes"
      return redirect_to(:action => 'edit', :id => group.id)
    end

    @attribute = group.tattributes.new(params[:attribute])
    if request.post?
      if @attribute.save
        redirect_to(:action => 'edit', :id => group.id)
      end
    end
  end

  # Edit a Attribute
  # ==== Params
  # * id = Attribute's id
  # * attribute = Hash of Attribute's attributes
  def edit_attribute
    @attribute = Attribute.find_by_id(params[:id])
    if request.post?
      if @attribute.update_attributes(params[:attribute])
        redirect_to(:action => 'edit', :id => @attribute.attributes_group.id)
      end
    end
  end

  # Destroy a Attribute
  # ==== Params
  # * id = Attribute's id
  def destroy_attribute
    @attribute = Attribute.find_by_id(params[:id])
    group = @attribute.attributes_group
    if @attribute.destroy
      render(:partial => 'list_attributes', :locals => { :group => group })
    end
  end

end
