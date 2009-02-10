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
    create_addresses if @order.user
    if @order.save
      flash[:notice] = 'Order successfully created'
    else
      flash[:error] = @order.errors
    end
  end

  def edit
    @order = Order.find_by_id(params[:id])
  end
  
  def update
    @order = Order.find_by_id(params[:id])
    create_addresses
    if @order.update_attributes(params[:order]) &&
      @order.address_invoice.update_attributes(params[:address_invoice]) &&
      @order.address_delivery.update_attributes(params[:address_delivery])
      flash[:notice] = 'Order successfully updated'
    else
      flash[:error] = @order.errors
    end
    render :action => 'edit'
  end

  def destroy
    @order = Order.find_by_id(params[:id])
    if @order.destroy
      flash[:notice] = 'Order was successfully destroyed'
    end
    render_list
  end

  def pay
    @order = Order.find_by_id(params[:id])
    flash[:notice] = 'Order was successfully paid' if @order.paid! == true
    render_list
  end

  def accept
    @order = Order.find_by_id(params[:id])
    flash[:notice] = 'Order was successfully accepted' if @order.accepted! == true
    render_list
  end

  def sent
    @order = Order.find_by_id(params[:id])
    flash[:notice] = 'Order was successfully sended' if @order.sended! == true
    render_list
  end

  def create_detail
    order = Order.find_by_id(params[:id])
    @orders_detail = order.orders_details.new(params[:orders_detail])
    if request.post?
      if @orders_detail.save
        flash[:notice] = 'Order Detail was successfully created'
        redirect_to(:action => 'edit', :id => order.id)
      else
        flash[:error] = @orders_detail.errors
      end
    end
    get_products
  end

  def edit_detail
    order = Order.find_by_id(params[:id])
    @orders_detail = order.orders_details.find_by_id(params[:detail_id])
    if request.post?
      if @orders_detail.update_attributes(params[:orders_detail])
        flash[:notice] = 'Order Detail was successfully updated'
      else
        flash[:error] = @orders_detail.errors
      end
    end
    get_products
  end

  def destroy_detail
    order = Order.find_by_id(params[:id])
    @orders_detail = order.orders_details.find_by_id(params[:detail_id])
    if @orders_detail.destroy
      flash[:notice] = 'Order detail was successfully destroyed'
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

  def create_addresses
    @order.address_invoice = AddressInvoice.create(params[:address_invoice]) if @order.address_invoice_id == @order.user.address_invoice.id && params[:address_invoice]
    @order.address_delivery = AddressDelivery.create(params[:address_delivery]) if @order.address_delivery_id == @order.user.address_delivery.id && params[:address_delivery]
  end

  def render_list
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

end
