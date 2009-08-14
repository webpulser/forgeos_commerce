class Admin::OrderDetailsController < Admin::BaseController
  before_filter :get_order
  before_filter :get_order_detail, :only => [:edit, :update, :destroy, :show]
  before_filter :new_order_detail, :only => [:new, :create]
  after_filter :get_products, :only => [:create, :update]
  
  def new
    @products = Product.all
    render 'create'
  end
  
  def create
    if request.post?
      if @orders_detail.save
        flash[:notice] = I18n.t('order_detail.create.success').capitalize
        redirect_to(:action => 'edit', :id => order.id)
      else
        flash[:error] = I18n.t('order_detail.create.failed').capitalize
      end
    end
  end
  
  def edit
  end
  
  def update
    if request.post?
      if @orders_detail.update_attributes(params[:orders_detail])
        flash[:notice] = I18n.t('order_detail.update.success').capitalize
      else
        flash[:error] = I18n.t('order_detail.update.failed').capitalize
      end
    end
  end
  
  def destroy
    if @orders_detail.destroy
      flash[:notice] = I18n.t('order_detail.destroy.success').capitalize
    end
    render :partial => 'list_details', :locals => { :order => order }
  end
  
private
  def get_order
    @order = Order.find_by_id(params[:id]) || Order.find_by_id(params[:order_id])
    unless @order
      flash[:error] = I18n.t('order.not_found').capitalize
      return redirect_to(admin_orders_path)
    end
  end

  def new_order_detail
    @orders_detail = @order.orders_details.new(params[:orders_detail])
  end
 
  def get_order_detail
    @orders_detail = @order.orders_details.find_by_id(params[:detail_id])
  end
 
  def get_products
    @products = Product.all
  end
end