class Admin::ShippingRulesController < Admin::BaseController

  def index

  end

  def show

  end

  def new

  end

  
#  0 = Weight / 1 = Type / 2 = Country
#  {"commit"=>"Save",
#   "rule_builder"=>{
#       "name"=>"",
#       "targets"=>["UPS"],
#       "description"=>""},
#   "authenticity_token"=>"D87xRei3O4/zDjqEyvjJq9KNaS7mAxvjGy7jEygavUY=",
#   "rule"=>{
#       "value"=>["1", "406850150"],
#       "target"=>["1",  "2"],
#       "conds"=>["==",  "=="]}
#   }


  def create

    @rule_condition = []
    @rule_condition << 'ShippingMethod' << ':shipping_method'

    if params[:rule_builder][:if] == 'All'
      @rule = ShippingRule.new
      @rule.name = params[:rule_builder][:name]
      @rule.description = params[:rule_builder][:description]

      params[:rule][:targets].each_with_index do |rule_target, index|
        build_a_rule(rule_target, index)
      end

      @rule.conditions = "[#{@rule_condition.join(', ')}]"
      #@rule.variables = variables
      @rule.save
    else
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule_condition = []
        @rule_condition << 'ShippingMethod' << ':shipping_method'
        @rule = ShippingRule.new
        @rule.name = params[:rule_builder][:name]
        @rule.description = params[:rule_builder][:description]

        build_a_rule(rule_target, index)

        @rule.conditions = "[#{@rule_condition.join(', ')}]"
        #@rule.variables = variables
        @rule.save
      end
    end

    return redirect_to :action => 'new'
    
  end

  def edit

  end

  def update

  end

  def destroy
    
  end

private

 def build_a_rule(rule_target, index)
    rule_target.downcase!
    case "#{rule_target}"
    when "0"
      target = "m.current_user.cart.weight"
    when "1"
      target =  "m.current_user.cart.products.type"
    when "2"
      target =  "m.current_user.country_id"
    end

    if params[:rule][:values][index].to_i == 0
      value = "'#{params[:rule][:values][index]}'"
    else
      value = params[:rule][:values][index]
    end
    @rule_condition << "#{target}.#{params[:rule][:conds][index]}(#{value})"
  end

end
