class Admin::OrdersController < Admin::BaseController
  def index
    @orders = Order.all
  end

  def show
    @order = Order.find_by_id(params[:id])
  end

  def new
    @order = Order.new(params[:order])
    render :action => 'create'
  end
  
  def create
    @order = Order.new(params[:order])
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
    @order = Order.find_by_id(params[:id])
  end
  
  def update
    @order = Order.find_by_id(params[:id])
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
    @order = Order.find_by_id(params[:id])
    if @order.destroy
      flash[:notice] = I18n.t('order.destroy.success').capitalize
    end
    render_list
  end

  def pay
    @order = Order.find_by_id(params[:id])
    flash[:notice] = I18n.t('order.pay.success').capitalize if @order.paid! == true
    render_list
  end

  def accept
    @order = Order.find_by_id(params[:id])
    flash[:notice] = I18n.t('order.accept.success').capitalize if @order.accepted! == true
    render_list
  end

  def sent
    @order = Order.find_by_id(params[:id])
    flash[:notice] = I18n.t('order.send.success').capitalize if @order.sended! == true
    render_list
  end

  def create_detail
    order = Order.find_by_id(params[:id])
    @orders_detail = order.orders_details.new(params[:orders_detail])
    if request.post?
      if @orders_detail.save
        flash[:notice] = I18n.t('order_detail.create.success').capitalize
        redirect_to(:action => 'edit', :id => order.id)
      else
        flash[:error] = I18n.t('order_detail.create.failed').capitalize
      end
    end
    get_products
  end

  def edit_detail
    order = Order.find_by_id(params[:id])
    @orders_detail = order.orders_details.find_by_id(params[:detail_id])
    if request.post?
      if @orders_detail.update_attributes(params[:orders_detail])
        flash[:notice] = I18n.t('order_detail.update.success').capitalize
      else
        flash[:error] = I18n.t('order_detail.update.failed').capitalize
      end
    end
    get_products
  end

  def destroy_detail
    order = Order.find_by_id(params[:id])
    @orders_detail = order.orders_details.find_by_id(params[:detail_id])
    if @orders_detail.destroy
      flash[:notice] = I18n.t('order_detail.destroy.success').capitalize
    end
    render :partial => 'list_details', :locals => { :order => order }
  end

  def get_product
    product = Product.find_by_id(params[:product_id])
    get_products
    render :partial => 'form_details', :locals => { :orders_detail => OrdersDetail.new(
      { :name => product.name, :description => product.description, :price => product.price, :rate_tax => product.rate_tax }),
    :products => @products }
  end

private
  def get_products
    @products = ProductDetail.all
  end

#  def create_addresses
#    @order.address_invoice = AddressInvoice.create(params[:address_invoice]) if params[:address_invoice]
#    @order.address_delivery = AddressDelivery.create(params[:address_delivery]) if params[:address_delivery]
#  end

  def render_list
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

end
