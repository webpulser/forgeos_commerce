# This Controller Manage Options and his association with
# Attributes
class Admin::OptionsController < Admin::BaseController

  before_filter :get_options, :only => [:index]
  before_filter :get_option, :only => [:edit, :update, :destroy, :show, :duplicate]
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
 
  def duplicate
    @option = @option.clone
    render :new
  end

  # Create an Option
  # ==== Params
  # * option = Hash of Option's attributes
  def create
    if @option.save
      flash[:notice] = I18n.t('tattribute.create.success').capitalize
      return redirect_to([:edit, :admin, @option])
    else
      flash[:error] = I18n.t('tattribute.create.failed').capitalize
      render :action => :new
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
    return redirect_to(admin_options_path)
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
    %w(checkbox_option picklist_option radiobutton_option
       text_option longtext_option number_option
       date_option url_option).each do |key|
      
    params[:option] = params[key] if params[key]
    end
  end
  
  def new_option
    case params[:type]
    when 'checkbox'
      params[:option] = params[:checkbox_option] if params[:checkbox_option]
      @option = CheckboxOption.new(params[:option])
    when 'radiobutton'
      params[:option] = params[:radiobutton_option] if params[:radiobutton_option]
      @option = RadiobuttonOption.new(params[:option])
    when 'picklist'
      params[:option] = params[:picklist_option] if params[:picklist_option]
      @option = PicklistOption.new(params[:option])
    when 'text'
      params[:option] = params[:text_option] if params[:text_option]
      @option = TextOption.new(params[:option])
    when 'longtext'
      params[:option] = params[:longtext_option] if params[:longtext_option]
      @option = LongtextOption.new(params[:option])
    when 'number'
      params[:option] = params[:number_option] if params[:number_option]
      @option = NumberOption.new(params[:option])
    when 'date'
      params[:option] = params[:date_option] if params[:date_option]
      @option = DateOption.new(params[:option])
    when 'url'
      params[:option] = params[:url_option] if params[:url_option]
      @option = UrlOption.new(params[:option])
    else
      @option = Tattribute.new(params[:option])
    end
  end

  def sort
    columns = %w(tattributes.type tattributes.name access_method)

    conditions = {}
    if params[:category_id]
      conditions[:option_categories_options] = { :option_category_id => params[:category_id] }
    end

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
    if params[:sSearch] && !params[:sSearch].blank?
      @options = Tattribute.search(params[:sSearch],
        :conditions => conditions,
        :include => :option_categories,
        :order => order,
        :page => page,
        :per_page => per_page)
    else
      @options = Tattribute.paginate(:all,
        :conditions => conditions,
        :include => :option_categories,
        :order => order,
        :page => page,
        :per_page => per_page)
    end
  end
end
