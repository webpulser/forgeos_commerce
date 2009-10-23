class Admin::VouchersController < Admin::BaseController
  before_filter :get_voucher, :only => [:destroy]
  
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
      when "Total weight"
        target = "m.weight"
      when "Total amount"
        target = "m.total)"
      else
        target = "m.#{rule_target})"
      end
    end

    if params[:rule][:values][index].to_i == 0
      value = "'#{params[:rule][:values][index]}'"
    else
      value = params[:rule][:values][index]
    end
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
      @vouchers = VoucherRule.search(params[:sSearch],options)
    else
      @vouchers = VoucherRule.paginate(:all,options)
    end
  end

end
