class Admin::OrdersController < Admin::BaseController
  before_filter :get_orders, :only => [:index]
  before_filter :new_order, :only => [:new, :create]
  before_filter :get_order, :only => [:show, :edit, :update, :destroy, :pay, :accept, :sent, :total]
  before_filter :get_civilities_and_countries, :only => [:new, :edit, :create, :update]

  after_filter :render_list, :only => [:pay, :accept, :sent]
  
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
      redirect_to(admin_orders_path)
    else
      flash[:error] = I18n.t('order.create.failed').capitalize
    end
  end

  def edit
  end
  
  def update
    if @order.update_attributes(params[:order])
      flash[:notice] = I18n.t('order.update.success').capitalize
      return render :text => true if request.xhr?
      redirect_to(admin_orders_path)
    else
      flash[:error] = I18n.t('order.update.failed').capitalize
      return render :text => false if request.xhr?
      render :action => 'edit'
    end
  end

  def destroy
    if @order.destroy
      flash[:notice] = I18n.t('order.destroy.success').capitalize
      return redirect_to(admin_orders_path) if !request.xhr?
    else
      flash[:error] = I18n.t('order.destroy.failed').capitalize
    end
    render :nothing => true
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
    render :partial => 'form_details', :locals => { :order_detail => OrdersDetail.new(
      { :name => product.name, :description => product.description, :price => product.price, :rate_tax => product.rate_tax }),
    :products => @products }
  end

  def total
    # clone order and order_shipping
    editing_order = @order.clone
    editing_order.order_shipping = @order.order_shipping.clone

    # get order_details ids
    if order_details = params[:order][:order_details_attributes]
      detail_ids = order_details.values.collect{ |detail| detail['id'].to_i if detail['id'] && detail['_delete'].to_i != 1 }
      detail_ids.compact!
      editing_order.order_detail_ids = detail_ids
    end

    # update attributes for order and order_shipping
    editing_order.attributes = params[:order]
    editing_order.order_shipping.attributes = params[:order][:order_shipping_attributes]

    # calculate total, subtotal and taxes
    total = editing_order.total
    subtotal = editing_order.total(false,true,false,false)
    #taxes = editing_order.taxes

    return render :json => { :result => 'success', :id => @order.id, :total => total, :subtotal => subtotal} #, :taxes => taxes}
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

  def get_civilities_and_countries
    @civilities = Civility.all :order => 'name ASC'
    @countries = Country.all :order => 'name ASC'
  end
    
  def render_list
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

  def sort
    columns = %w(id id sum(order_details.price) count(order_details.id) created_at people.lastname status)
    conditions = {}
    case params[:filter]
    when 'status'
      conditions[:status] = params[:status]
    when 'user'
      conditions[:user_id] = params[:user_id]
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
      include_models << 'order_details'
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
