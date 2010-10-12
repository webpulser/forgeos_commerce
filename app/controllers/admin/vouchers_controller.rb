class Admin::VouchersController < Admin::BaseController
  before_filter :get_voucher, :only => [:activate,:destroy]

  def activate
    render :text => @voucher.activate
  end

  def new
    @default_attributes = %w(price title description weight sku stock product_type_id brand_id).collect do |n|
      [t(n, :count => 1), n]
    end
    @attributes = Attribute.all(:joins => [:translations], :select => 'access_method,name').collect{|a| [a.name, a.access_method]}
    @cart_attributes = [[t(:quantity,:scope=>[:special_offer,:cart]),'Total items quantity'],[t(:weight,:scope=>[:special_offer,:cart]), 'Total weight'], [t(:price,:scope=>[:special_offer,:cart]),'Total amount'],[t(:shipping,:scope=>[:special_offer,:cart]),'Shipping method']]
    @disable_attributes = t(:disabled,:scope=>[:special_offer,:attributes])

    @for = Hash["Cart", "Cart"]

    @condition_is = Hash["Is", "=="]
    @conditions =  Hash["Is not", "not==","Equals or greater than",">=","Equals or less than","<=", "Greater than", ">", "Less than","<"]

    @end = [[t(:date,:scope=>[:special_offer,:end]),'Date'],[t(:total_use,:scope=>[:special_offer,:end]),'Total number of offer use'],[t(:user_total_use,:scope=>[:special_offer,:end]),'Customer number of offer use']]
    @products = Product.find_all_by_active_and_deleted(true,false, :select => 'products.id,name', :joins => [:translations])
    @discount_type = [[t(:percent,:scope=>[:special_offer,:action]),0],[t(:fixed,:scope=>[:special_offer,:action]),1]]
    @product_attributes = [t(:main,:scope=>[:special_offer,:attributes,:disabled])]+@default_attributes+[t(:attribute,:scope=>[:special_offer,:attributes,:disabled])]+@attributes
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  def create
    return flash[:error] = 'Fields' unless params[:rule_builder]

    @main_attributes = %w(price title description weight sKU stock)

    @rule_condition = []
    @rule_condition << params[:rule_builder]['for'] << ':product'

    # Build Action variables
    variables = {}
    params[:act][:targets].each_with_index do |action, index|
      case "#{action}"
      when "Discount price this product"
        variables[:discount] = params[:act][:values][index].to_i
        variables[:fixed_discount] = (params[:act][:conds][index] == "By percent" ? false : true)
      when "Offer a product"
        variables[:product_ids] = [params[:act][:values][index].to_i]
      when "Offer free delivery"
        variables[:shipping] = 'free'
      when "Discount cart"
        variables[:cart_discount] = params[:act][:values][index]
        variables[:percent] = (params[:act][:conds][index] == "By percent" ? false : true)
      end
    end

    if params[:rule_builder][:if] == 'All'
      @rule = VoucherRule.new
      @rule.code = params[:voucher_code]
      @rule.name = params[:rule_builder][:name]
      @rule.description = params[:rule_builder][:description]
      @rule.active = params[:rule_builder][:active]

      params[:rule][:targets].each_with_index do |rule_target, index|
        build_a_rule(rule_target, index)
      end

      if params[:rule_builder]['for'] == 'Category'
        @rule_condition << "m.category.=(#{params[:rule_builder][:target]})"
      end

      @rule.conditions = "[#{@rule_condition.join(', ')}]"
      @rule.variables = variables
      @rule.save
    else
      rule_parent = nil
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule_condition = []
        @rule_condition << params[:rule_builder]['for'] << ':product'
        @rule = VoucherRule.new
        @rule.parent = rule_parent
        @rule.name = params[:rule_builder][:name]
        @rule.code = params[:voucher_code]
        @rule.description = params[:rule_builder][:description]

        build_a_rule(rule_target, index)

        if params[:rule_builder]['for'] == 'Category'
          @rule_condition << "m.category.=(#{params[:rule_builder][:target]})"
        end

        @rule.conditions = "[#{@rule_condition.join(', ')}]"
        @rule.variables = variables
        @rule.save
        rule_parent = @rule if index == 0
      end
    end

    # TODO : Update this ugly patch for vouchers to work with packs
    if params[:rule_builder]['for'] == 'Product'
      params[:rule_builder]['for'] = 'Pack'
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule_condition = []
        @rule_condition << params[:rule_builder]['for'] << ':pack'
        @rule = VoucherRule.new
        @rule.parent = rule_parent
        @rule.name = params[:rule_builder][:name]
        @rule.code = params[:voucher_code]
        @rule.description = params[:rule_builder][:description]

        build_a_rule(rule_target, index)

        @rule.conditions = "[#{@rule_condition.join(', ')}]"
        @rule.variables = variables
        @rule.save
        rule_parent = @rule if index == 0
      end
    end
    redirect_to :action => 'index'
  end

  def build_a_rule(rule_target, index)
    rule_target.downcase!
    if @main_attributes.include?(rule_target)
      if rule_target == 'title' || rule_target == 'Title'
        target = "m.name"
      else
        target = "m.#{rule_target}"
      end
    else
      p "TARGET => #{rule_target}"
      case "#{rule_target}"
      when "total items quantity"
        target = "m.total_items"
      when "total weight"
        target = "m.weight"
      when "total amount"
        target = "m.total"
      else
        target = "m.#{rule_target}"
      end
    end


=begin
     TODO : find why it was written like this

    if params[:rule][:values][index].to_i == 0
      #value = "'#{params[:rule][:values][index]}'"
    else
      #value = params[:rule][:values][index]
    end
=end
    value = params[:rule][:values][index].to_i
    @rule_condition << "#{target}.#{params[:rule][:conds][index]}(#{value})"
  end


  def destroy
    if @voucher.destroy
      flash[:notice] = "Voucher destroy"
    else
      flash[:error] = "Voucher not destroy"
    end
    redirect_to :action => 'index'
  end

private

  def get_voucher
    @voucher = VoucherRule.find_by_id(params[:id])
  end

  def sort
    columns = %w(rules.name rules.name active code rules.use)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"

    conditions = { :parent_id => nil }
    options = { :page => page, :per_page => per_page }

    includes = []
    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :voucher_categories
    end

    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @vouchers = VoucherRule.search(params[:sSearch],options)
    else
      @vouchers = VoucherRule.paginate(:all,options)
    end
  end

end
