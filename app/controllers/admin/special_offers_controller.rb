require 'ruleby'

class Admin::SpecialOffersController < Admin::BaseController
  include Ruleby
  before_filter :get_special_offer, :only => [:activate, :show, :destroy]

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

  def create
    return flash[:error] = 'Fields' unless params[:rule_builder]

    # GENERATE RULE !!!!!!!
    # Parameters: {"commit"=>"Save", "rule_builder"=>{"stop"=>"0",   "title"=>"", "if"=>"Any", "target"=>"Computer", "description"=>"", "for"=>["Product"]},
    #             "authenticity_token"=>"JZ3F3oEKmMB0rhQf6xHljskHTDH2aPP53unToh3SLwU=", "end_offer"=>"1",
    #             "end"=>{"targets"=>["Total number of offer use"], "values"=>["324"], "conds"=>["Is"]},
    #             "end_offer_if"=>"Any", "act"=>{"targets"=>["Offer a product"], "values"=>["Macbook"]},
    #             "rule"=>{"targets"=>["Price", "Stock"], "values"=>["24", "100"], "conds"=>["==", "=="]}}

    @main_attributes = %w(price title description weight sku stock product_type_id)

    @rule_condition = []
    if params[:rule_builder]['for'] == 'Category'
      @rule_condition << 'Product'
    else
      @rule_condition << params[:rule_builder]['for']
    end
    @rule_condition << ':product'

    # Build Action variables
    variables = {}
    params[:act][:targets].each_with_index do |action, index|
      case "#{action}"
      when '0'
        variables[:discount] = params[:act][:values][index].to_i
        variables[:fixed_discount] = (params[:act][:conds][index] == '0' ? false : true)
      when '1'
        variables[:product_ids] = [params[:act][:values][index].to_i]
      when '2'
        variables[:shipping_ids] = params[:act][:values][index]
      when '3'
        variables[:cart_discount] = params[:act][:values][index]
        variables[:percent] = (params[:act][:conds][index] == '0' ? false : true)
      end
    end

    if params[:rule_builder][:if] == 'All'
      @rule = SpecialOfferRule.new
      @rule.name = params[:rule_builder][:name]
      @rule.description = params[:rule_builder][:description]
      @rule.active = params[:rule_builder][:active]

      params[:rule][:targets].each_with_index do |rule_target, index|
        build_a_rule(rule_target, index)
      end

      if params[:rule_builder]['for'] == 'Category'
        @rule_condition << "m.has_category_#{params[:rule_builder][:target]}.==(true)"
      end

      @rule.conditions = "[#{@rule_condition.join(', ')}]"
      @rule.variables = variables
      @rule.save
    else
      rule_parent = nil
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule_condition = []
        if params[:rule_builder]['for'] == 'Category'
          @rule_condition << 'Product'
        else
          @rule_condition << params[:rule_builder]['for']
        end
        @rule_condition << ':product'
        @rule = SpecialOfferRule.new
        @rule.parent = rule_parent
        @rule.name = params[:rule_builder][:name]
        @rule.description = params[:rule_builder][:description]

        build_a_rule(rule_target, index)

        if params[:rule_builder]['for'] == 'Category'
          @rule_condition << "m.has_category_#{params[:rule_builder][:target]}.==(true))"
        end

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
      if rule_target == 'title'
        target = "name"
      else
        target = "#{rule_target}"
      end
    else
      case "#{rule_target}"
      when "total items quantity"
        target = "total_items"
      when "total weight"
        target = "weight"
      when "total amount"
        target = "total_with_tax"
      else
        target = "#{rule_target}"
      end
    end

    value = params[:rule][:values][index]
    value_column = Product.columns_hash[target]
    # if String type then add ''
    if value_column.nil? or [:string, :text].include?(value_column.type)
      value = "'#{value}'"
    end
    @rule_condition << "m.#{target}.#{params[:rule][:conds][index]}(#{value})"
  end

  def new
    t = Time.now
    @default_attributes = %w(price title description weight sku stock product_type_id).collect do |n|
      [t(n, :count => 1), n]
    end
    @attributes = Attribute.all.collect{|a| [a.name, a.access_method]}
    @cart_attributes = [[t(:quantity,:scope=>[:special_offer,:cart]),'Total items quantity'],[t(:weight,:scope=>[:special_offer,:cart]), 'Total weight'], [t(:price,:scope=>[:special_offer,:cart]),'Total amount'],[t(:shipping,:scope=>[:special_offer,:cart]),'Shipping method']]
    @disable_attributes = t(:disabled,:scope=>[:special_offer,:attributes])

    @for = [[t(:category,:scope=>[:special_offer,:_for]), 'Category'],[t(:product_in_shop,:scope=>[:special_offer,:_for]), 'Product'],[t(:product_in_cart,:scope=>[:special_offer,:_for]), 'Product'], [t(:cart,:scope=>[:special_offer,:_for]), 'Cart']]

    @conditions =  [[t(:is,:scope=>[:special_offer,:conditions]), "=="],[t(:is_not,:scope=>[:special_offer,:conditions]),"not=="],[t(:equal_or_greater_than,:scope=>[:special_offer,:conditions]),">="],[t(:equal_or_less_than,:scope=>[:special_offer,:conditions]),"<="], [t(:greater_than,:scope=>[:special_offer,:conditions]), ">"],[t(:less_than,:scope=>[:special_offer,:conditions]),"<"]]

    @product_attributes = [t(:main,:scope=>[:special_offer,:attributes,:disabled])]+@default_attributes+[t(:attribute,:scope=>[:special_offer,:attributes,:disabled])]+@attributes
    @end = [[t(:date,:scope=>[:special_offer,:end]),'Date'],[t(:total_use,:scope=>[:special_offer,:end]),'Total number of offer use'],[t(:user_total_use,:scope=>[:special_offer,:end]),'Customer number of offer use']]
    @discount_type = [[t(:percent,:scope=>[:special_offer,:action]),0],[t(:fixed,:scope=>[:special_offer,:action]),1]]

    @products = Product.find_all_by_active_and_deleted(true, false, :joins => [:translations], :select => 'products.id,name,sku', :order => 'sku')
  end

  def destroy
    if @special_offer.destroy
      flash[:notice] = t('special_offer.destroy.success')
    else
      flash[:error] = t('special_offer.destroy.failed')
    end
    redirect_to :action => 'index'
  end

  def show
    @selected_products = []
    engine :special_offer_engine do |e|
      rule_builder = SpecialOffer.new(e)
      rule_builder.rule_id = params[:id]
      rule_builder.selected_products = @selected_products
      rule_builder.rules
      products = Product.all(:conditions => {:active => true, :deleted=>[false, nil]})
      products.each do |product|
        e.assert product
      end
      e.match
    end
  end

  def preview
  end

private

  def get_special_offer
    unless @special_offer = SpecialOfferRule.find_by_id(params[:id])
      flash[:error] = t('special_offer.found.failed')
      redirect_to(admin_special_offers_path)
    end
  end

  def sort
    columns = %w(rules.name rules.name active rules.use)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"

    conditions = { :parent_id => nil }
    options = { :page => page, :per_page => per_page }

    includes = []
    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      includes << :special_offer_categories
    end

    options[:conditions] = conditions unless conditions.empty?
    options[:include] = includes unless includes.empty?
    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @special_offers = SpecialOfferRule.search(params[:sSearch],options)
    else
      @special_offers = SpecialOfferRule.paginate(:all,options)
    end
  end
end
