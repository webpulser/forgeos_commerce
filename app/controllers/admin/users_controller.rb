# This controller Manage Users
class Admin::UsersController < Admin::BaseController

  before_filter :get_user, :only => [:show, :activate, :edit, :update, :destroy]
  before_filter :new_user, :only => [:new, :create]
  before_filter :get_addresses, :only => [:create, :update]

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
    end
  end

  def update
    upload_avatar 
    if @user.update_attributes(params[:user]) &&
      @user.address_invoice.update_attributes(params[:address_invoice]) &&
      @user.address_delivery.update_attributes(params[:address_delivery]) &&
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

    index
    render :partial => 'list', :locals => { :users => @users }
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
      index
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
    conditions_ini = [[]]
    if @country.blank?
      conditions_ini[0] <<  'civility_id IN (?)'
      conditions_ini << gender
    else
      conditions_ini[0] << 'civility_id IN (?) AND country_id = ?'
      conditions_ini << gender
      conditions_ini <<@country.to_i
    end

    unless @v_age.nil? && @c_age.nil?

      old_date = (Date.today << @v_age*12)
      
      case @c_age
        when '=='
          conditions_ini[0] << 'birthday BETWEEN ? AND ?'
          conditions_ini << (old_date << 12)
        when '!='
          conditions_ini[0] << 'birthday NOT BETWEEN ? AND ?'
          conditions_ini << (old_date << 12)
        when '>='
          conditions_ini[0] << 'birthday <= ?'
        when '<='
          conditions_ini[0] << 'birthday >= ?'
        when '<'
          conditions_ini[0] << 'birthday > ?'
        when '>'
          conditions_ini[0] << 'birthday < ?'
      end
      conditions_ini << old_date
    end

    conditions_ini[0] = conditions_ini[0].join(' AND ')
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
  end

  def get_addresses
    @user.build_address_invoice(params[:address_invoice]) unless @user.address_invoice
    @user.build_address_delivery(params[:address_delivery]) unless @user.address_delivery
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

end
