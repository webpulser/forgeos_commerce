class Admin::OrdersController < Admin::BaseController
  before_filter :get_orders, :only => [:index]
  before_filter :get_order, :only => [:show, :edit, :update, :destroy, :pay, :accept, :sent]
  before_filter :new_order, :only => [:new, :create]
  after_filter :render_list, :only => [:destroy, :pay, :accept, :sent]
  before_filter :build_addresses, :only => [:create, :update]
  
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
    render :action => 'create'
  end
  
  def create
    if @order.save
      flash[:notice] = I18n.t('order.create.success').capitalize
    else
      flash[:error] = I18n.t('order.create.failed').capitalize
    end
  end

  def edit
  end
  
  def update
    if @order.update_attributes(params[:order])
      flash[:notice] = I18n.t('order.update.success').capitalize
    else
      flash[:error] = I18n.t('order.update.failed').capitalize
    end
    render :action => 'edit'
  end

  def destroy
    if @order.destroy
      flash[:notice] = I18n.t('order.destroy.success').capitalize
    end
  end

  def pay
    flash[:notice] = I18n.t('order.pay.success').capitalize if @order.pay! == true
  end

  def accept
    flash[:notice] = I18n.t('order.accept.success').capitalize if @order.accept! == true
  end

  def sent
    flash[:notice] = I18n.t('order.send.success').capitalize if @order.start_shipping! == true
  end

  def get_product
    product = Product.find_by_id(params[:product_id])
    @products = Product.all
    render :partial => 'form_details', :locals => { :orders_detail => OrdersDetail.new(
      { :name => product.name, :description => product.description, :price => product.price, :rate_tax => product.rate_tax }),
    :products => @products }
  end

private

  def get_orders
    @orders = Order.all
  end
  
  def get_order
    @order = Order.find_by_id(params[:id])
  end
  
  def new_order
    @order = Order.new(params[:order])
  end
  
  def build_addresses
    unless @order.build_address_invoice(params[:address_invoice])
      @order.address_invoice = @order.user.address_invoice
    end
    unless @order.build_address_delivery(params[:address_delivery])
      @order.address_delivery = @order.user.address_delivery
    end
  end
  
  def render_list
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

  def sort
    columns = %w(id id sum(orders_details.price) count(orders_details.id) created_at people.lastname status)
    conditions = [[]]
    case params[:filter]
    when 'status'
      conditions[0] << 'status = ?'
      conditions << params[:status]
    end
    conditions[0] = conditions[0].join(' AND ')
    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1

    order_column = columns[params[:iSortCol_0].to_i]
    include_models = []
    group_by = ['orders.id']

    case order_column
    when 'count(orders_details.id)', 'sum(orders_details.price)'
      group_by << 'orders_details.id'
      include_models << 'orders_details'
    when 'people.lastname'
      group_by << 'people.id'
      include_models << 'user'
    end
    group_by = group_by.join(',')
        
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
