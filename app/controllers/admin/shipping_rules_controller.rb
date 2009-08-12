class Admin::ShippingRulesController < Admin::BaseController

  def index
    @shipping_rules = ShippingRule.all
  end

  def show

  end

  def new

  end

  def create

    @variables = {}

    # Action
    case "#{params[:act][:targets]}"
      when "Discount price"
        @variables[:discount] = params[:act][:values].to_i
        @variables[:fixed_discount] = (params[:act][:conds] == "By percent" ? false : true)
      when "Increase price"
        @variables[:increase] = params[:act][:values].to_i
        @variables[:fixed_increase] = (params[:act][:conds] == "By percent" ? false : true)
      when "Offer free delivery"
        @variables[:free_delivery] = true
    end

    # Conditions
    @rule_condition = []
    @rule_condition << 'ShippingMethod' << ':shipping_method'

    # If All conditions should be true
    if params[:rule_builder][:if] == 'All'

      params[:rule][:targets].each_with_index do |rule_target, index|
        build_a_rule(rule_target, index)
      end

      # End of Rule
      if params[:end_offer].to_i == 1
        # If All ending conditions should be true
        if params[:end_offer_if] == 'All'
          params[:end][:targets].each_with_index do |e, i|
            case "#{e}"
              when "Date"
                @rule_condition << "m.date.#{params[:end][:conds][i]}#{params[:end][:values][i]}"
              when "Total number of offer use"
                @rule.max_use = params[:end][:values][i]
            end
          end
          save_rule
        # If Any ending conditions should be true
        else
          # TODO ANY
        end

      else
        save_rule
      end
    # If Any Conditions should be true
    else
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule_condition = []
        @rule_condition << 'ShippingMethod' << ':shipping_method'

        build_a_rule(rule_target, index)

        # End of Rule
        if params[:end_offer].to_i == 1
          # If All ending conditions should be true
          if params[:end_offer_if] == 'All'
            params[:end][:targets].each_with_index do |e, i|
              case "#{e}"
                when "Date"
                  @rule_condition << "m.date.#{params[:end][:conds][i]}#{params[:end][:values][i]}"
                when "Total number of offer use"
                  @rule.max_use = params[:end][:values][i]
              end
            end

            save_rule
          # If Any ending conditions should be true
          else
            # TODO ANY
          end

        # If there are any ending conditions
        else
          save_rule
        end
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

  def save_rule
    rule = ShippingRule.new
    rule.name = params[:rule_builder][:name]
    rule.description = params[:rule_builder][:description]
    rule.conditions = "[#{@rule_condition.join(', ')}]"
    rule.variables = @variables
    rule.save
  end

end
