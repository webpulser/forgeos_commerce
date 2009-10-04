class Admin::TransportersController < Admin::BaseController

  before_filter :new_transporter, :only => [:new, :create]
  before_filter :get_transporter, :only => [ :show, :edit, :update, :destroy, :create_shipping_method, :edit_shipping_method, :destroy_shipping_method ]

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
    @rule_condition = []
    @rule_condition << params[:delivery_type] << ':product'

    values = params[:delivery_rule][:values]
    conds = params[:delivery_rule][:conds]

    values.each_with_index do |value,  index|
      @rule_condition << "m.weight.#{conds[index]}#{value}"
    end

    @transporter.conditions = "[#{@rule_condition.join(', ')}]"
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
