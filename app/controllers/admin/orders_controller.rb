class Admin::OrdersController < Admin::BaseController
  before_filter :get_orders, :only => [:index]
  before_filter :get_order, :only => [:show, :edit, :update, :destroy, :pay, :accept, :sent]
  before_filter :new_order, :only => [:new, :create]
  after_filter :render_list, :only => [:destroy, :pay, :accept, :sent]
  
  def index
  end

  def show
  end

  def new
    render :action => 'create'
  end
  
  def create
    if params[:address_invoice] && address_invoice = AddressInvoice.create(params[:address_invoice])
      @order.address_invoice = address_invoice
    else
      @order.address_invoice = @order.user.address_invoice
    end
    if params[:address_delivery] && address_delivery = AddressDelivery.create(params[:address_delivery])
      @order.address_delivery = address_delivery
    else
      @order.address_delivery = @order.user.address_delivery
    end
    if @order.save
      flash[:notice] = I18n.t('order.create.success').capitalize
    else
      flash[:error] = I18n.t('order.create.failed').capitalize
    end
  end

  def edit
  end
  
  def update
    if address_invoice = AddressInvoice.create(params[:address_invoice])
      @order.address_invoice = address_invoice
    else
      @order.address_invoice = @order.user.address_invoice
    end
    if address_delivery = AddressDelivery.create(params[:address_delivery])
      @order.address_delivery = address_delivery
    else
      @order.address_delivery = @order.user.address_delivery
    end
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
    flash[:notice] = I18n.t('order.pay.success').capitalize if @order.paid! == true
  end

  def accept
    flash[:notice] = I18n.t('order.accept.success').capitalize if @order.accepted! == true
  end

  def sent
    flash[:notice] = I18n.t('order.send.success').capitalize if @order.sended! == true
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
  
  def render_list
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

end
