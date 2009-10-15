class Admin::TransporterRulesController < Admin::BaseController

  before_filter :new_transporter, :only => [:new, :create]
  before_filter :get_transporter, :only => [ :show, :edit, :update ]

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

    @shipping_methods = params[:shipping_method]

    @shipping_methods.each do |shipping_method|

      new_shipping_method = shipping_method == @shipping_methods.first ? TransporterRule.new(params[:transporter_rule]) : TransporterRule.new

      rule_condition = []
      rule_condition << 'Product' << ':cart'

      shipping_method[1][:values].each_with_index do |value, index|

        case params[:delivery_type]
          when 'weight'
            condition = "m.#{params[:delivery_type]}"
          when 'geo_zone'
            condition = "m.geo_zone_id"
          when 'product_type'
            condition = "m.product_type.id"
          when 'product'
            condition = "m.id"
        end

        condition += ".#{shipping_method[1][:conds][index]}(#{value})"
        rule_condition << condition
      end

      new_shipping_method.conditions = "[#{rule_condition.join(', ')}]"
      new_shipping_method.variables = shipping_method[1][:price][0]

      new_shipping_method.save
      
      shipping_method == @shipping_methods.first ? @parent_id = new_shipping_method.id : new_shipping_method.update_attribute(:parent_id, @parent_id)
      
    end

    return redirect_to(admin_transporters_path)
      
    
#      flash[:error] = I18n.t('transporter.create.failed').capitalize
#      render :action => :new
  end
  
  def edit
  end

  def update
    if @transporter.update_attributes(params[:transporter_rule])
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
      unless @transporter = TransporterRule.find_by_id(params[:id])
        flash[:notice] = I18n.t('transporter.not_exist').capitalize
        return redirect_to(admin_transporters_path)
      end
    end

    def new_transporter
      @transporter = TransporterRule.new(params[:transporter_rule])
    end

    def sort
      columns = %w(id name active)

      per_page = params[:iDisplayLength].to_i
      offset =  params[:iDisplayStart].to_i
      page = (offset / per_page) + 1
      order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
      
      options = {
        :conditions => { :parent_id => nil },
        :order => order,
        :page => page,
        :per_page => per_page
      }
      if params[:sSearch] && !params[:sSearch].blank?
        @transporters = TransporterRule.search(params[:sSearch],options)
      else
        @transporters = TransporterRule.paginate(:all,options)
      end
    end
end
