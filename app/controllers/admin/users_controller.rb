# This controller Manage Users
class Admin::UsersController < Admin::BaseController

  before_filter :get_user, :only => [:show, :activate, :edit, :update, :destroy]
  before_filter :new_user, :only => [:new, :create]

  # List all users
  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  # Display an User
  # ==== Params 
  # * <i>id</i> = User's id
  def show
  end

  def new
  end

  # Edit an User
  # ==== Params
  # * <i>id</i> = User's id
  # * <i>user</i> = Hash of User attributes
  # * <i>address_invoice</i> = Hash of Railscommerce::AddressInvoice attributes
  # * <i>address_delivery</i> = Hash of Railscommerce::AddressDelivery attributes
  def edit
    respond_to do |format|
      format.html
      format.json do
        sort_orders
        render :layout => false
      end
    end
  end

  # Create an User
  # ==== Params
  # * <i>user</i> = Hash of User attributes
  # * <i>address_invoice</i> = Hash of Railscommerce::AddressInvoice attributes
  # * <i>address_delivery</i> = Hash of Railscommerce::AddressDelivery attributes
  def create
    if @user.avatar.nil? && params[:avatar] && params[:avatar][:uploaded_data] && params[:avatar][:uploaded_data].blank?
      @user.build_avatar(params[:avatar])
    end
    if @user.save
      flash[:notice] = I18n.t('user.create.success').capitalize
      return redirect_to([:admin, @user])
    else
      flash[:error] = I18n.t('user.create.failed').capitalize
      render :new
    end
  end

  def update
    upload_avatar 
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('user.update.success').capitalize
    else
      flash[:error] = I18n.t('user.update.failed').capitalize
    end
    render :action => 'edit'
  end

  # Remotly Destroy an User
  # return the list of all users
  def destroy
    if @user.destroy
      flash[:notice] = I18n.t('user.destroy.success').capitalize
    else
      flash[:error] = I18n.t('user.destroy.failed').capitalize
    end

    return redirect_to(admin_users_path)
  end
	
  def activate
    unless @user.active?
      if @user.activate
        flash[:notice] = I18n.t('user.activation.success').capitalize
      else
        flash[:error] = I18n.t('user.activation.failed').capitalize
      end
    else
      if @user.disactivate
        flash[:notice] = I18n.t('user.disactivation.success').capitalize
      else
        flash[:error] = I18n.t('user.disactivation.failed').capitalize
      end
    end
    if request.xhr?
      render(:partial => 'list', :locals => { :users => @users })
    else
      return redirect_to(:back)
    end
  end

  # example action to return the contents
  # of a table in CSV format
  def export_newsletter
    require 'fastercsv'
    return flash[:error] = I18n.t('user.export.failed').capitalize if @users.empty?
    stream_csv do |csv|
      csv << %w[name email]	
      @users.each do |u|
        csv << [u.fullname,u.email]
      end
    end
  end

  # Filter users by something, only by gender & country for the moment
  def filter
    return redirect_to(:action => 'index') unless params[:filter]

    @gender = params[:filter][:gender]
    @country = params[:filter][:country]

    @v_age = params[:filter][:age][:values].to_i
    @c_age = params[:filter][:age][:conds]

    gender = @gender.chomp.split(',').collect(&:to_i)
    conditions_ini = {}
    conditions_ini[:civility_id] = gender
    unless @country.blank?
      conditions_ini[:country_id] = @country.to_i
    end

    unless @v_age.nil? && @c_age.nil?

      old_date = (Date.today << @v_age*12)
      
      case @c_age
        when '=='
          conditions_ini[:birthday] = old_date.ago(12.month)..old_date
        when '!='
          conditions_ini[:birthday_not] = old_date.ago(12.month)..old_date
        when '>='
          conditions_ini[:birthday_lte] = old_date
        when '<='
          conditions_ini[:birthday_gte] = old_date
        when '<'
          conditions_ini[:birthday_gt] = old_date
        when '>'
          conditions_ini[:birthday_lt] = old_date
      end
    end

    @users = User.all( :conditions => conditions_ini )
    
    flash[:error] = I18n.t('user.search.failed').capitalize if @users.empty?

    return export_newsletter if params[:commit] == I18n.t('export').capitalize
    render :template => 'admin/users/index'
  end

private

  def get_user
    unless @user = User.find_by_id(params[:id])
      flash[:notice] = I18n.t('user.not_exist').capitalize
      return redirect_to(admin_users_path)
    end
  end

  def new_user
    @user = User.new(params[:user])
    @user.address_deliveries.build if @user.address_deliveries.empty?
    @user.address_invoices.build if @user.address_invoices.empty?
  end

  def stream_csv
     filename = params[:action] + ".csv"
      
     #this is required if you want this to work with IE		
     if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers["Content-type"] = 'text/plain'
       headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
       headers['Expires'] = "0"
     else
       headers['Content-Type'] ||= 'text/csv'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
     end

    render :text => Proc.new { |response, output|
			def output.<<(*args)
				write(*args)
			end
      csv = FasterCSV.new(output, :row_sep => "\r\n")
      yield csv
    }
  end

  def upload_avatar
    if @user && params[:avatar] && params[:avatar][:uploaded_data] && !params[:avatar][:uploaded_data].blank?
      @avatar = @user.create_avatar(params[:avatar])
      flash[:error] = @avatar.errors unless @avatar.save
      params[:user].update(:avatar_id => @avatar.id)
    end
  end

  def sort
    columns = %w(lastname email order total last_order joined_on)
    conditions = []
    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
    if params[:sSearch] && !params[:sSearch].blank?
      @users = User.search(params[:sSearch],
        :order => order,
        :page => page,
        :per_page => per_page)
    else
      @users = User.paginate(:all,
        :conditions => conditions,
        :order => order,
        :page => page,
        :per_page => per_page)
    end
  end

  def sort_orders
    columns = %w(id id sum(order_details.price) count(order_details.id) created_at  status)
    conditions = { :user_id => @user.id}
    case params[:filter]
      when 'status'
        conditions[:status] = params[:status]
    end

    if params[:category_id]
      conditions[0] << 'user_categories_users'
      conditions << { :user_category_id => params[:category_id] }
    end
    
    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1

    order_column = columns[params[:iSortCol_0].to_i]
    include_models = []
    group_by = ['orders.id']

    case order_column
    when 'count(order_details.id)', 'sum(order_details.price)'
      group_by << 'order_details.id'
      include_models << :order_details
    when 'people.lastname'
      group_by << 'people.id'
      include_models << :user
    end
    include_models << 'user_categories'
    group_by = group_by.join(',')

    p include_models

    order = "#{order_column} #{params[:iSortDir_0].upcase}"
    if params[:sSearch] && !params[:sSearch].blank?
      @orders = Order.search(params[:sSearch],
        :include => include_models,
        :group => group_by,
        :order => order,
        :page => page,
        :per_page => per_page)
    else
      @orders = Order.paginate(:all,
        :conditions => conditions,
        :include => include_models,
        :group => group_by,
        :order => order,
        :page => page,
        :per_page => per_page)
    end
  end

end
