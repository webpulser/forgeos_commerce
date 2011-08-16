require 'ruleby'
class Admin::SpecialOffersController < Admin::BaseController
  before_filter :get_special_offer, :only => [:activate, :show, :destroy]
  include Ruleby

  def activate
    render :text => @special_offer.activate
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
      [t(:product_in_shop,:scope=>[:special_offer,:_for]), 'Product'],
      [t(:product_in_cart,:scope=>[:special_offer,:_for]), 'Product'],
      [t(:cart,:scope=>[:special_offer,:_for]), 'Cart']
    ]

    @for << [t(:category,:scope=>[:special_offer,:_for]), 'Category'] if ProductCategory.count > 0

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
    @products = Product.actives(:select => 'products.id, sku', :order => 'sku')
  end

  def create
    return flash[:error] = 'Fields' unless params[:rule_builder]

    @main_attributes = %w(price name description weight sku stock product_type_id brand_id)

    conditions = []
    params[:rule][:targets].each_with_index do |rule_target, index|
      conditions << generate_condition(rule_target, index)
    end

    if params[:rule_builder]['for'] == 'Category'
      conditions << "m.has_category_#{params[:rule_builder][:target]}.==(true)"
    end

    matchers = if params[:rule_builder]['for'] == 'Cart'
      ['Cart',':cart']
    else
      [':is_a?', 'Product',':product']
    end

    generate_rule(matchers, conditions, generate_variables, (params[:rule_builder][:if] == 'Any'))

    redirect_to :action => 'index'
  end

  def destroy
    if @special_offer.destroy
      flash[:notice] = t('special_offer.destroy.success')
    else
      flash[:error] = t('special_offer.destroy.failed')
    end
    respond_to do |wants|
      wants.html do
        redirect_to([forgeos_commerce, :admin, :special_offers])
      end
      wants.js
    end
  end

  def show
    @selected_products = []
    sql_options = {:page => 1, :per_page => 100, :conditions => {:active => true, :deleted=> false} }
    pagination = Product.paginate(sql_options)

    pagination.total_pages.enum_for(:times).each do |page|
      sql_options[:page] = page+1
      engine :special_offer_engine do |e|
        rule_builder = SpecialOffer.new(e)
        rule_builder.selected_products = @selected_products
        rule_builder.rule_preview(@special_offer)
        Product.paginate(sql_options).each do |product|
          e.assert product
        end
        e.match
      end
    end
  end

  def preview
  end

private

  def get_special_offer
    unless @special_offer = SpecialOfferRule.find_by_id(params[:id])
      flash[:error] = t('special_offer.found.failed')
      redirect_to([forgeos_commerce, :admin, :special_offers])
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
        variables[:fixed_discount] = (params[:act][:conds][index] != '0')
      end
    end
    return variables
  end

  def generate_rule(matchers,conditions,variables, or_rule = false)
    rule = SpecialOfferRule.new
    rule.name = params[:rule_builder][:name]
    rule.description = params[:rule_builder][:description]
    rule.active = params[:rule_builder][:active]
    rule.conditions = if or_rule
      "OR(#{conditions.map{ |condition| "[#{(matchers + [condition]).join(', ')}]" }.join(', ')})"
    else
      "[#{(matchers + conditions).join(', ')}]"
    end
    rule.variables = variables
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
      custom_attribute = Attribute.find_by_access_method(target)
      value = "'#{value}'"
      target = "#{target}_value" if custom_attribute
    end

    return "m.#{target}.#{params[:rule][:conds][index]}(#{value})"
  end

  def sort
    columns = %w(rules.name rules.name active rules.use)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:sSortDir_0].upcase}"

    conditions = { :parent_id => nil }
    options = { :page => page, :per_page => per_page }

    includes = []
    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :categories
    end

    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @special_offers = SpecialOfferRule.search(params[:sSearch],options)
    else
      @special_offers = SpecialOfferRule.paginate(options)
    end
  end
end
