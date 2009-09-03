# This Controller Manage Options and his association with
# Attributes
class Admin::OptionsController < Admin::BaseController
  before_filter :get_options, :only => [:index]
  before_filter :get_option, :only => [:edit, :update, :destroy, :show]
  before_filter :new_option, :only => [:new, :create]
  
  # List Options
  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  def show
  end

  def new
  end

  # Create an Option
  # ==== Params
  # * option = Hash of Option's attributes
  def create
    if @option.save
      flash[:notice] = I18n.t('tattribute.create.success').capitalize
      redirect_to([:edit, :admin, @option])
    else
      flash[:error] = I18n.t('tattribute.create.failed').capitalize
    end
  end

  # Edit an Option
  # ==== Params
  # * id = Option's id
  def edit
  end

  def update
    if @option.update_attributes(params[:option])
      flash[:notice] = I18n.t('tattribute.update.success').capitalize
    else
      flash[:error] = I18n.t('tattribute.update.failed').capitalize
    end
    render :action => 'edit'
  end

  # Destroy an Option
  # ==== Params
  # * id = Option's id
  def destroy
    if @option.destroy
      flash[:notice] = I18n.t('tattribute.destroy.success').capitalize
    else
      flash[:error] = I18n.t('tattribute.destroy.failed').capitalize
    end
    return redirect_to(admin_options_path)
  end

  def access_method
    render :text => Forgeos::url_generator(params[:access_method])
  end

private
  def get_options
    @options = Tattribute.all
  end
  
  def get_option
    unless @option = Tattribute.find_by_id(params[:id])
      flash[:error] = I18n.t('tattribute.not_exist').capitalize
      return redirect_to(admin_options_path)
    end
    params[:option] = params[:checkbox_option] if params[:checkbox_option]
  end
  
  def new_option
    params[:option] = params[:checkbox_option] if params[:checkbox_option]
    case params[:option][:type]
       when 'CheckboxOption'
         @option = CheckboxOption.new(params[:option])
    end
  end
  
  def sort
    columns = %w(id name actions)
    conditions = []
    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
    if params[:sSearch] && !params[:sSearch].blank?
      @options = Tattribute.search(params[:sSearch],
        :order => order,
        :page => page,
        :per_page => per_page)
    else
      @options = Tattribute.paginate(:all,
        :conditions => conditions,
        :order => order,
        :page => page,
        :per_page => per_page)
    end
  end
end