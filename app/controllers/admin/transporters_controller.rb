class Admin::TransportersController < Admin::BaseController

  before_filter :new_transporter, :only => [:new, :create]
  before_filter :get_transporter, :only => [ :show, :edit, :update, :destroy, :create_shipping_method, :edit_shipping_method, :destroy_shipping_method ]

  before_filter :new_shipping_method, :only => [:new, :create]
  before_filter :get_shipping_method, :only => [ :edit_shipping_method, :destroy_shipping_method]

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

  def create

    # Parameters: {"commit"=>"Create transporter", "action"=>"create", "authenticity_token"=>"ulSiBSIy2bYzmtuZJKEF1rwxssrl37ZBKAOgkawNIn0=",
    # "transporter"=>{"name"=>"La Poste", "activated"=>"0"}, "controller"=>"admin/transporters", "delivery_rule"=>{"delivery_type"=>["Weight base rate"], "values"=>["20", "200"], "conds"=>[">", "<"], "prices"=>["12"]}}


    # [Cart, :product, m.weight.>(10), m.weight.=Underwear]
    @rule_condition = []
    @rule_condition << params[:delivery_type] << ':product'


    values = params[:delivery_rule][:values]
    conds = params[:delivery_rule][:conds]

    values.each_with_index do |value,  index|
      @rule_condition << "m.weight.#{conds[index]}#{value}"
    end

    @transporter.conditions = "[#{@rule_condition.join(', ')}]"

    p @transporter


#    if @transporter.save
#      flash[:notice] = I18n.t('transporter.create.success').capitalize
#      redirect_to([:admin, @transporter])
#    else
#      flash[:error] = I18n.t('transporter.create.failed').capitalize
#      render :new
#    end
  end
  
  def edit
  end

  def update
    if @transporter.update_attributes(params[:transporter])
      flash[:notice] = I18n.t('transporter.update.success').capitalize
    else
      flash[:error] = I18n.t('transporter.update.failed').capitalize
    end
    render :edit
  end

  def destroy
    if @transporter.destroy
      flash[:notice] = I18n.t('transporter.destroy.success').capitalize
      render :partial => 'list', :locals => { :transporters => @transporters }
    else
      flash[:error] = I18n.t('transporter.destroy.failed').capitalize
      render :nothing => true
    end
  end

  def activate
    render :text => @transporter.activate
  end
  
  def new_shipping_method
  end

  def create_shipping_method
    if request.post?
      if @shipping_method.save
        flash[:notice] = I18n.t('shipping_method.create.success').capitalize
        redirect_to(:action => 'edit', :id => @transporter.id)
      else
        flash[:error] = I18n.t('shipping_method.create.failed').capitalize
        render :new_shipping_method
      end
    end
  end

  def edit_shipping_method
  end

  def update_shipping_method
    if request.post?
      if @shipping_method.update_attributes(params[:shipping_method])
        flash[:notice] = I18n.t('shipping_method.update.success').capitalize
      else
        flash[:error] = I18n.t('shipping_method.update.failed').capitalize
      end
    end
    render :edit_shipping_method
  end

  def destroy_shipping_method
    if @shipping_method.destroy
      flash[:notice] = I18n.t('shipping_method.destroy.success').capitalize
      render :partial => 'list_details', :locals => { :transporter => @transporter }
    end
  end

  private
    def get_transporter
      @transporter = Transporter.find_by_id(params[:id])
    end

    def get_shipping_method
      @shipping_method = @transporter.shipping_methods.find_by_id(params[:shipping_method])
    end

    def new_transporter
      @transporter = Transporter.new(params[:transporter])
    end

    def new_shipping_method
      @shipping_method = @transporter.shipping_methods.new(params[:shipping_method])
    end

    def sort
      columns = %w(id name activated)

      per_page = params[:iDisplayLength].to_i
      offset =  params[:iDisplayStart].to_i
      page = (offset / per_page) + 1
      order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
      
      if params[:sSearch] && !params[:sSearch].blank?
        @transporters = Transporter.search(params[:sSearch],
          :order => order,
          :page => page,
          :per_page => per_page)
      else
        @transporters = Transporter.paginate(:all,
          :order => order,
          :page => page,
          :per_page => per_page)
      end
    end



end
