# This Controller Manage Tattributes and his association with
# Attributes
class Admin::TattributesController < Admin::BaseController
  # List Tattribute
  def index
    @tattributes = Tattribute.all
  end

  def new
    @tattribute = Tattribute.new(params[:tattribute])
    render :action => 'create'
  end

  # Create a Tattribute
  # ==== Params
  # * tattribute = Hash of Tattribute's attributes
  def create
    @tattribute = Tattribute.new(params[:tattribute])
    if @tattribute.save
      flash[:notice] = I18n.t('tattribute.create.success').capitalize
      redirect_to([:edit, :admin, @tattribute])
    else
      flash[:error] = I18n.t('tattribute.create.failed').capitalize
    end
  end

  # Edit a Tattribute
  # ==== Params
  # * id = Tattribute's id
  def edit
    @tattribute = Tattribute.find_by_id(params[:id])
  end

  def update
    @tattribute = Tattribute.find_by_id(params[:id])
    if @tattribute.update_attributes(params[:tattribute])
      flash[:notice] = I18n.t('tattribute.update.success').capitalize
    else
      flash[:error] = I18n.t('tattribute.update.failed').capitalize
    end
    render :action => 'edit'
  end

  # Destroy a Tattribute
  # ==== Params
  # * id = Tattribute's id
  def destroy
    @tattribute = Tattribute.find_by_id(params[:id])
    if @tattribute.destroy
      flash[:notice] = I18n.t('tattribute.destroy.success').capitalize
    else
      flash[:error] = I18n.t('tattribute.destroy.failed').capitalize
    end
    return redirect_to(:action => 'index')
  end

end
