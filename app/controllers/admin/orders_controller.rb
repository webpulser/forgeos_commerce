class Admin::OrdersController < Admin::BaseController
  def index
    @orders = Order.all
  end

  def show
    @order = Order.find_by_id(params[:id])
  end

  def create
    @order = Order.new(params[:order])
    if request.post?
      if @order.user
        @order.address_invoice = AddressInvoice.create(params[:address_invoice]) if @order.address_invoice_id == @order.user.address_invoice.id && params[:address_invoice]
        @order.address_delivery = AddressDelivery.create(params[:address_delivery]) if @order.address_delivery_id == @order.user.address_delivery.id && params[:address_delivery]
      end
      if @order.save
        flash[:notice] = 'Order successfully created'
      else
        flash[:error] = @order.errors
      end
    end
  end

  def edit
    @order = Order.find_by_id(params[:id])
    @order.address_invoice = AddressInvoice.create(params[:address_invoice]) if @order.address_invoice_id == @order.user.address_invoice.id && params[:address_invoice]
    @order.address_delivery = AddressDelivery.create(params[:address_delivery]) if @order.address_delivery_id == @order.user.address_delivery.id && params[:address_delivery]
    if request.post?
      if @order.update_attributes(params[:order]) && @order.address_invoice.update_attributes(params[:address_invoice]) && @order.address_delivery.update_attributes(params[:address_delivery])
        flash[:notice] = 'Order successfully updated'
      else
        flash[:error] = @order.errors
      end
    end
  end

  def destroy
    @order = Order.find_by_id(params[:id])
    if @order.destroy
      flash[:notice] = 'Order was successfully destroyed'
    end
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

  def pay
    @order = Order.find_by_id(params[:id])
    if @order.paid! == true
      flash[:notice] = 'Order was successfully paid'
    end
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

  def accept
    @order = Order.find_by_id(params[:id])
    if @order.accepted! == true
      flash[:notice] = 'Order was successfully accepted'
    end
    index
    render :partial => 'list', :locals => { :orders => @orders } 
  end

  def sent
    @order = Order.find_by_id(params[:id])
    if @order.sended! == true
      flash[:notice] = 'Order was successfully sended'
    end
    index
    render :partial => 'list', :locals => { :orders => @orders } 
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

end
