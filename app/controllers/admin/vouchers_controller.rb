class Admin::VouchersController < Admin::BaseController
  before_filter :get_voucher, :only => [:activate,:destroy]

  def activate
    render :text => @voucher.activate
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

  def new
    @default_attributes = %w(price name description weight sku stock product_type_id brand_id).collect do |n|
      [t(n, :count => 1), n]
    end

    @attributes = Attribute.all(:select => 'id, access_method').collect do |a|
      [a.name, a.access_method]
    end

    @cart_attributes = [
      [t(:quantity,:scope=>[:special_offer,:cart]),'Total items quantity'],
      [t(:weight,:scope=>[:special_offer,:cart]), 'Total weight'],
      [t(:price,:scope=>[:special_offer,:cart]),'Total amount'],
      [t(:shipping,:scope=>[:special_offer,:cart]),'Shipping method']
    ]

    @disable_attributes = t(:disabled,:scope=>[:special_offer,:attributes])

    @for = [
      [t(:product_in_cart,:scope=>[:special_offer,:_for]), 'Product'],
      [t(:cart,:scope=>[:special_offer,:_for]), 'Cart']
    ]

    @conditions = [
      [t(:is,:scope=>[:special_offer,:conditions]), "=="],
      [t(:is_not,:scope=>[:special_offer,:conditions]),"not=="],
      [t(:equal_or_greater_than,:scope=>[:special_offer,:conditions]),">="],
      [t(:equal_or_less_than,:scope=>[:special_offer,:conditions]),"<="],
      [t(:greater_than,:scope=>[:special_offer,:conditions]), ">"],
      [t(:less_than,:scope=>[:special_offer,:conditions]),"<"]
    ]

    @end = [
      [t(:date,:scope=>[:special_offer,:end]),'Date'],
      [t(:total_use,:scope=>[:special_offer,:end]),'Total number of offer use'],
      [t(:user_total_use,:scope=>[:special_offer,:end]),'Customer number of offer use']
    ]

    @discount_type = [
      [t(:percent,:scope=>[:special_offer,:action]),0],
      [t(:fixed,:scope=>[:special_offer,:action]),1]
    ]

    @product_attributes = [t(:main,:scope=>[:special_offer,:attributes,:disabled])]+
      @default_attributes+
      [t(:attribute,:scope=>[:special_offer,:attributes,:disabled])]+
      @attributes
    @products = Product.actives(:select => 'products.id,sku', :order => 'sku')
  end

  def create
    return flash[:error] = 'Fields' unless params[:rule_builder]

    @main_attributes = %w(price name description weight sku stock product_type_id brand_id)

    @variables = generate_variables

    if params[:rule_builder][:if] == 'All'
      conditions = []
      params[:rule][:targets].each_with_index do |rule_target, index|
        conditions << generate_condition(rule_target, index)
      end

      if params[:rule_builder]['for'] == 'Cart'
        generate_rule(['Cart',':cart'] + conditions, @variables)
      else
        generate_rule(['Product',':product'] + conditions, @variables)
        generate_rule(['Pack',':pack'] + conditions, @variables)
      end
    else
      rule_parent = nil
      params[:rule][:targets].each_with_index do |rule_target, index|
        conditions = [generate_condition(rule_target, index)]
        if params[:rule_builder]['for'] == 'Cart'
          rule = generate_rule(
            ['Cart',
            ':cart',
            conditions],
            @variables,
            rule_parent
          )
          rule_parent = rule if index == 0
        else
          rule = generate_rule(
            ['Product',
            ':product',
            conditions],
            @variables,
            rule_parent
          )
          rule_parent = rule if index == 0

          pack_rule = generate_rule(
            ['Pack',
            ':pack',
            conditions],
            @variables,
            rule_parent
          )
        end
      end
    end
    redirect_to :action => 'index'
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
    unless @voucher = VoucherRule.find_by_id(params[:id])
      flash[:error] = t('voucher.found.failed')
      redirect_to(admin_vouchers_path)
    end
  end

  def generate_variables
    # Build Action variables
    variables = {}
    params[:act][:targets].each_with_index do |action, index|
      case "#{action}"
      when '0'
        variables[:discount] = params[:act][:values][index].to_i
        variables[:fixed_discount] = (params[:act][:conds][index] != '0')
      when '1'
        variables[:product_ids] ||= []
        variables[:product_ids] << params[:act][:values][index].to_i
      when '2'
        variables[:shipping] = true
      when '3'
        variables[:cart_discount] = params[:act][:values][index]
        variables[:percent] = (params[:act][:conds][index] != '0')
      end
    end
    return variables
  end

  def generate_rule(conditions,variables, rule_parent = nil)
    rule = VoucherRule.new
    rule.name = params[:rule_builder][:name]
    rule.code = params[:voucher_code]
    rule.description = params[:rule_builder][:description]
    rule.active = params[:rule_builder][:active]
    rule.conditions = "[#{conditions.join(', ')}]"
    rule.variables = variables
    rule.parent = rule_parent
    rule.save
    return rule
  end

  def generate_condition(rule_target, index)
    rule_target = rule_target.parameterize('_').to_s
    target = case rule_target
    when 'total_items_quantity'
      'total_items'
    when 'total_weight'
      'weight'
    when 'total_amount'
      'total'
    when 'shipping_method'
      'transporter_id'
    else
      rule_target
    end

    value = params[:rule][:values][index]

    # if String type then add ''
    value_column = Product.columns_hash[target] ||
      Product::Translation.columns_hash[target]
    if (value_column and [:string, :text].include?(value_column.type)) or
      Attribute.find_by_access_method(target)
      value = "'#{value}'"
    end

    return "m.#{target}.#{params[:rule][:conds][index]}(#{value})"
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
