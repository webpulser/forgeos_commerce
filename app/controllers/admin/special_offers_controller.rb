class Admin::SpecialOffersController < Admin::BaseController
  def special_offer
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
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule_condition = []
        @rule_condition << params[:rule_builder]['for'] << ':product'
        @rule = SpecialOfferRule.new
        @rule.name = params[:rule_builder][:name]
        @rule.description = params[:rule_builder][:description]
        
        build_a_rule(rule_target, index)
        
        if params[:rule_builder]['for'] == 'Category'
          @rule_condition << "m.category.=(#{params[:rule_builder][:target]})"
        end
        
        @rule.conditions = "[#{@rule_condition.join(', ')}]" 
        @rule.variables = variables
        @rule.save
      end
    end
  end
  
  def build_a_rule(rule_target, index)
    rule_target.downcase!
    if @main_attributes.include?(rule_target)
      target = "m.#{rule_target}"
    else
      case "#{rule_target}"
      when "Total items quantity"
        target = "m.carts_products.count"
      when "Total weight"
        target = "m.weight"
      when "Total amount"
        target = "m.total"
      when "Shipping method"
        target = "m.ShippingMethodDetail"
      else
        target = "m.get_attribute(#{rule_target})"
      end
    end

    if params[:rule][:values][index].to_i == 0
      value = "'#{params[:rule][:values][index]}'"
    else
      value = params[:rule][:values][index]
    end
    @rule_condition << "#{target}.#{params[:rule][:conds][index]}(#{value})"
  end
  
end
