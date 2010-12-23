require 'ruleby'

class Admin::OrdersController < Admin::BaseController
  include Ruleby
  before_filter :get_orders, :only => [:index]
  before_filter :new_order, :only => [:new, :create]
  before_filter :get_order, :only => [:show, :edit, :update, :destroy, :pay, :accept, :sent, :total]
  before_filter :get_civilities_and_countries, :only => [:new, :edit, :create, :update]
  before_filter :get_available_transporters, :only => [:edit]

  after_filter :render_list, :only => [:pay, :accept, :sent]
  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render(:layout => false)
      end
    end
  end

  def show
  end

  def new
    render(:action => 'create')
  end

  def create
    if @order.save
      flash[:notice] = t('order.create.success').capitalize
      redirect_to edit_admin_order_path(@order)
    else
      flash[:error] = t('order.create.failed').capitalize
      render(:action => 'edit')
    end
  end

  def edit
  end

  def update
    if @order.update_attributes(params[:order])
      flash[:notice] = t('order.update.success').capitalize
      return render(:text => true) if request.xhr?
    else
      flash[:error] = t('order.update.failed').capitalize
      return render(:text => false) if request.xhr?
    end
    render(:action => 'edit')
  end

  def destroy
    if @order.destroy
      flash[:notice] = t('order.destroy.success').capitalize
      return redirect_to(admin_orders_path) if !request.xhr?
    else
      flash[:error] = t('order.destroy.failed').capitalize
    end
    render(:nothing => true)
  end

  def pay
    flash[:notice] = t('order.pay.success').capitalize if @order.pay! == true
  end

  def accept
    flash[:notice] = t('order.accept.success').capitalize if @order.accept! == true
  end

  def sent
    flash[:notice] = t('order.send.success').capitalize if @order.start_shipping! == true
  end

  def get_product
    product = Product.find_by_id(params[:product_id])
    @products = Product.all
    render(:partial => 'form_details', :locals => { :order_detail => OrdersDetail.new(
      { :name => product.name, :description => product.description, :price => product.price, :rate_tax => product.rate_tax }
    ), :products => @products })
  end

  def total
    if @order.nil?
      @order = Order.new
      @order.order_shipping = OrderShipping.new
    end
    # clone order and order_shipping
    editing_order = @order.clone
    editing_order.order_shipping = @order.order_shipping.clone
    # get order_details ids

    if order_details = params[:order][:order_details_attributes]
      detail_ids = order_details.values.collect{ |detail| detail['id'].to_i if detail['id'] && detail['_destroy'].to_i != 1 }.uniq.compact
      editing_order.order_detail_ids = detail_ids
    end

    # update attributes for order and order_shipping
    editing_order.attributes = params[:order]
    editing_order.order_shipping.attributes = params[:order][:order_shipping_attributes]

    @transporter_ids = []
    if params[:transporter][:rebuild].to_i == 1
      # get new available transporters
      @order = editing_order
      engine :transporter_engine do |e|
        rule_builder = Transporter.new(e)
        rule_builder.transporter_ids = @transporter_ids
        rule_builder.order = @order
        rule_builder.rules
        @order.order_details.each do |order_detail|
          e.assert order_detail.product
        end
        e.assert @order
        e.match
      end
    end

    @available_transporters = TransporterRule.find_all_by_id(@transporter_ids.uniq)

    #total(with_tax=false, with_currency=true,with_shipping=true,with_special_offer=false)

    # calculate total, subtotal and taxes
    total = editing_order.total
    subtotal = editing_order.total(false,true,false,false,false)
    #taxes = editing_order.taxes

    return render(:json => { :result => 'success', :id => @order.id, :total => total, :subtotal => subtotal, :available_transporters =>  @available_transporters, :rebuild_transporter => params[:transporter][:rebuild].to_i}) #, :taxes => taxes}
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
    user = User.find_by_id(params[:user_id])
    if user
      @order.user = user
      @order.address_delivery = user.address_delivery
      @order.address_invoice = user.address_invoice
    end
    @available_transporters = TransporterRule.find_all_by_active(true)
  end

  def get_civilities_and_countries
    @civilities = t('civility.select')
    @countries = Country.all :order => 'name ASC'
  end

  def get_available_transporters
    @transporter_ids = []
    engine :transporter_engine do |e|
      rule_builder = Transporter.new(e)
      rule_builder.transporter_ids = @transporter_ids
      rule_builder.order = @order
      rule_builder.rules
      @order.order_details.each do |order_detail|
        e.assert order_detail.product
      end
      e.assert @order
      e.match
    end
    @available_transporters = TransporterRule.find_all_by_id(@transporter_ids.uniq)
  end

  def render_list
    index
    render(:partial => 'list', :locals => { :orders => @orders })
  end

  def sort
    columns = %w(id id sum(order_details.price) count(order_details.id) created_at people.lastname status)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1

    conditions = {}
    options = { :page => page, :per_page => per_page }

    case params[:filter]
    when 'status'
      conditions[:status] = params[:status]
    when 'user'
      conditions[:user_id] = params[:user_id]
    else
      conditions[:status_ne] = %w(unpaid closed)
    end

    order_column = params[:iSortCol_0].to_i
    includes = []
    group_by = []

    case order_column
    when 2, 3
      group_by << 'orders.id'
      includes << :order_details
    when 5
      includes << :user
    end

    order = "#{columns[order_column]} #{params[:iSortDir_0].upcase}"

    options[:group] = group_by.join(', ') unless group_by.empty?
    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @orders = Order.search(params[:sSearch],options)
    else
      @orders = Order.paginate(:all,options)
    end
  end
end
