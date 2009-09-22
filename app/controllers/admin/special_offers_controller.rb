class Admin::SpecialOffersController < Admin::BaseController
  
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
        variables[:shipping_ids] = params[:act][:values][index]
      when "Discount cart"
        variables[:cart_discount] = params[:act][:values][index]
        variable[:percent] = (params[:act][:conds][index] == "By percent" ? false : true)
      end
    end
    
    if params[:rule_builder][:if] == 'All'
      @rule = SpecialOfferRule.new
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
        @rule = SpecialOfferRule.new
        @rule.parent = rule_parent
        @rule.name = params[:rule_builder][:name]
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
      target = "m.#{rule_target}"
    else
      case "#{rule_target}"
      when "Total items quantity"
        target = "m.total_items"
      when "Total weight"
        target = "m.weight"
      when "Total amount"
        target = "m.total_with_tax)"
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
  
  #def index
  #  @special_offers = SpecialOfferRule.find_all_by_parent_id(nil)
  #end

  def show
    
  end
  
  def new
  
  end
  
  def destroy
    @special_offer = SpecialOfferRule.find_by_id(params[:id])
    if @special_offer && request.delete?  
      if @special_offer.destroy
        flash[:notice] = "Special offer destroy"
      else
        flash[:error] = "Special offer not destroy"
      end
    else
      flash[:error] = "Special offer does not exist"
    end
    redirect_to :action => 'index'
  end
  
private

  def sort
    columns = %w(name activated use)
    #if params[:category_id]
    #  conditions[:product_category_id] = params[:category_id]
    #end
    #conditions = 'parent_id = NULL'
    #conditions[:deleted] = params[:deleted] ? true : [false,nil]

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"
    if params[:sSearch] && !params[:sSearch].blank?
      @special_offers = SpecialOfferRule.search(params[:sSearch],
        :conditions => ["rules.parent_id is NULL"],
        #:include => ['product_categories'],
        :order => order,
        :page => page,
        :per_page => per_page)
    else
      @special_offers = SpecialOfferRule.paginate(:all,
        :conditions => ["rules.parent_id is NULL"],
        #:include => ['product_categories'],
        :order => order,
        :page => page,
        :per_page => per_page)
    end
  end
  
end
