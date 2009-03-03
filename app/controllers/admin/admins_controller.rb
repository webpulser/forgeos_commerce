class Admin::AdminsController < Admin::BaseController
  # GET /admins
  # GET /admins.xml
  def index
    @admins = Admin.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admins }
    end
  end

  # GET /admins/1
  # GET /admins/1.xml
  def show
    @admin = Admin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  # GET /admins/new
  # GET /admins/new.xml
  def new
    @admin = Admin.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  # GET /admins/1/edit
  def edit
    @admin = Admin.find(params[:id])
  end

  # POST /admins
  # POST /admins.xml
  def create
    @admin = Admin.new(params[:admin])
    @admin.build_avatar(params[:avatar]) unless @admin.avatar
    respond_to do |format|
      if @admin.save
        flash[:notice] = I18n.t('admin.create.success').capitalize
        format.html { redirect_to(admin_admin_path(@admin)) }
        format.xml  { render :xml => @admin, :status => :created, :location => @admin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admins/1
  # PUT /admins/1.xml
  def update
    @admin = Admin.find(params[:id])
    upload_avatar 
    
    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        flash[:notice] = I18n.t('admin.update.success').capitalize
        format.html { redirect_to(admin_admin_path(@admin)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.xml
  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy

    respond_to do |format|
      format.html { redirect_to(admin_admins_path) }
      format.xml  { head :ok }
    end
  end

  def update_rights
    @admin = Admin.find_by_id(params[:id])
    @roles = Role.find_all_by_id(params[:admin][:role_ids])
    @rights = []
    @roles.each do |role| 
      @rights += role.rights
    end
    render :layout => false
  end

private
  def upload_avatar
    if @admin && params[:avatar] && params[:avatar][:uploaded_data] && !params[:avatar][:uploaded_data].blank?
      @avatar = @admin.create_avatar(params[:avatar])
      flash[:error] = @avatar.errors unless @avatar.save
      params[:admin].update(:avatar_id => @avatar.id)
    end
  end
end
