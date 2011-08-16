class Admin::UsersController < Admin::BaseController
  def edit
    respond_to do |format|
      format.html
      format.json do
        sort_orders
        render :layout => false
      end
    end
  end

private

  def new_user
    @user = User.new(params[:user])
    @user.address_deliveries.build if @user.address_deliveries.empty?
    @user.address_invoices.build if @user.address_invoices.empty?
  end

  def sort
    columns = %w(lastname lastname email count(orders.id) '' max(orders.created_at) created_at activated_at)

    per_page = params[:iDisplayLength] ? params[:iDisplayLength].to_i : 10
    offset = params[:iDisplayStart] ? params[:iDisplayStart].to_i : 0
    page = (offset / per_page) + 1
    order_column = params[:iSortCol_0].to_i
    order = "#{columns[order_column]} #{params[:sSortDir_0] ? params[:sSortDir_0].upcase : 'ASC'}"

    conditions = {}
    includes = []
    group_by = []
    options = { :order => order, :page => page, :per_page => per_page }

    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :user_categories
    end

    case order_column
    when 3, 5
      group_by << 'people.id'
      includes << :orders
    end

    options[:group] = group_by.join(', ') unless group_by.empty?
    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @users = User.search(params[:sSearch],options)
    else
      @users = User.paginate(options)
    end
  end

  def sort_orders
    columns = %w(id id sum(order_details.price) count(order_details.id) created_at people.lastname status)

    per_page = params[:iDisplayLength] ? params[:iDisplayLength].to_i : 10
    offset = params[:iDisplayStart] ? params[:iDisplayStart].to_i : 0
    page = (offset / per_page) + 1

    conditions = {}
    options = { :page => page, :per_page => per_page }

    case params[:filter]
    when 'status'
      conditions[:status] = params[:status]
    when 'user'
      conditions[:user_id] = params[:user_id]
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

    order = "#{columns[order_column]} #{params[:sSortDir_0] ? params[:sSortDir_0].upcase : 'ASC'}"

    options[:group] = group_by.join(', ') unless group_by.empty?
    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @orders = Order.search(params[:sSearch],options)
    else
      @orders = Order.paginate(options)
    end
  end
end
