# This Controller Manage Tattributes and his association with
# Attributes
class Admin::TattributesController < Admin::BaseController
  before_filter :get_tattributes, :only => [:index]
  before_filter :get_tattribute, :only => [:edit, :update, :destroy, :show]
  before_filter :new_tattribute, :only => [:new, :create]
  
  # List Tattribute
  def index
  end

  def new
    render :action => 'create'
  end

  # Create a Tattribute
  # ==== Params
  # * tattribute = Hash of Tattribute's attributes
  def create
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
  end

  def update
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
    if @tattribute.destroy
      flash[:notice] = I18n.t('tattribute.destroy.success').capitalize
    else
      flash[:error] = I18n.t('tattribute.destroy.failed').capitalize
    end
    return redirect_to(:action => 'index')
  end

private
  def get_tattributes
    @tattributes = Tattribute.all
  end
  
  def get_tattribute
    @tattribute = Tattribute.find_by_id(params[:id])
  end
  
  def new_tattribute
    @tattribute = Tattribute.new(params[:tattribute])
  end
end