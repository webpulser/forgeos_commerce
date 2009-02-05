# This controller Manage Users
class Admin::UsersController < Admin::BaseController
  # List all users
  def index
    @users = User.all
  end

  # Display an User
  # ==== Params 
  # * <i>id</i> = User's id
  def show
    @user = User.find_by_id(params[:id])
  end

  def activate
    @user = User.find_by_id(params[:id])
    @user.activate
    if request.xhr? 
      index
      return render :partial => 'list', :locals => { :users => @users }
    else
      return redirect_to :back
    end
  end

  # Create an User
  # ==== Params
  # * <i>user</i> = Hash of User attributes
  # * <i>address_invoice</i> = Hash of Railscommerce::AddressInvoice attributes
  # * <i>address_delivery</i> = Hash of Railscommerce::AddressDelivery attributes
  def create
    @user = User.new(params[:user])
    @user.build_address_invoice(params[:address_invoice]) unless @user.address_invoice
    @user.build_address_delivery(params[:address_delivery]) unless @user.address_delivery
    @user.build_avatar(params[:avatar]) unless @user.avatar
    if request.post?
      if @user.save
        flash[:notice] = 'User successfully created'
      else
        flash[:error] = @user.errors
      end
    end
  end

  # Edit an User
  # ==== Params
  # * <i>id</i> = User's id
  # * <i>user</i> = Hash of User attributes
  # * <i>address_invoice</i> = Hash of Railscommerce::AddressInvoice attributes
  # * <i>address_delivery</i> = Hash of Railscommerce::AddressDelivery attributes
  def edit
    @user = User.find_by_id(params[:id])
    @user.build_address_invoice(params[:address_invoice]) unless @user.address_invoice
    @user.build_address_delivery(params[:address_delivery]) unless @user.address_delivery
    if request.post?
      upload_avatar 
      if @user.update_attributes(params[:user]) &&
        @user.address_invoice.update_attributes(params[:address_invoice]) &&
        @user.address_delivery.update_attributes(params[:address_delivery]) &&
        flash[:notice] = 'User successfully updated'
      else
        flash[:error] = @user.errors
      end
    end
  end

  # Remotly Destroy an User
  # return the list of all users
  def destroy
    @user = User.find_by_id(params[:id])
    if @user.destroy
      flash[:notice] = 'User successfully destroyed'
    else
      flash[:error] = @user.errors
    end
    index
    render :partial => 'list', :locals => { :users => @users }
  end


  # example action to return the contents
  # of a table in CSV format
  def export_newsletter
    require 'fastercsv'
    users = User.find(:all)
    stream_csv do |csv|
      csv << %w[name email]
      users.each do |u|
        csv << [u.fullname,u.email]
      end
    end
  end

private
  def stream_csv
     filename = params[:action] + ".csv"    
      
     #this is required if you want this to work with IE		
     if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers["Content-type"] = "text/plain"
       headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
       headers['Expires'] = "0"
     else
       headers["Content-Type"] ||= 'text/csv'
       headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
     end

    render :text => Proc.new { |response, output|
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

end
