class Admin::ShippingRulesController < Admin::BaseController

  def index
    @shipping_rules = ShippingRule.all
  end

  def show

  end

  def new

  end

  def create

    # Action
    variables = {}
    case "#{params[:act][:targets]}"
      when 'Discount price'
        variables[:discount] = params[:act][:values].to_i
        variables[:fixed_discount] = (params[:act][:conds] == 'By percent' ? false : true)
      when 'Increase price'
        variables[:increase] = params[:act][:values].to_i
        variables[:fixed_increase] = (params[:act][:conds] == 'By percent' ? false : true)
      when 'Offer free delivery'
        variables[:free_delivery] = true
    end

    # Conditions
    conditions = []
    conditions << 'Cart' << ':cart'

    # If All conditions should be true
    if params[:rule_builder][:if] == 'All'

      params[:rule][:targets].each_with_index do |rule_target, index|
        build_a_rule(rule_target, index, conditions)
      end

      # End of Rule
      if params[:end_offer].to_i == 1

        # If All ending conditions should be true
        if params[:end_offer_if] == 'All'
          ends = {}
          params[:end][:targets].each_with_index do |e, i|
            case "#{e}"
              when 'Date'
                ends[:date] = "m.created_at.#{params[:end][:conds][i]}#{params[:end][:values][i]}"
              when 'Total number of offer use'
                ends[:max_use] = params[:end][:values][i]
            end
          end
          
          save_rule(variables, conditions.dup, ends)
          
        # If Any ending conditions should be true
        elsif params[:end_offer_if] == 'Any'
          params[:end][:targets].each_with_index do |e, i|
            ends = {}
            case "#{e}"
              when 'Date'
                ends[:date] = "m.created_at.#{params[:end][:conds][i]}#{params[:end][:values][i]}"
              when 'Total number of offer use'
                ends[:max_use] = params[:end][:values][i]
            end
            save_rule(variables, conditions.dup, ends)
          end
        end

      else
        save_rule(variables, conditions.dup)
      end

    # If Any Conditions should be true
    else params[:rule_builder][:if] == 'Any'
      params[:rule][:targets].each_with_index do |rule_target, index|
        
        conditions = []
        conditions << 'Cart' << ':cart'

        build_a_rule(rule_target, index, conditions)

        # End of Rule
        if params[:end_offer].to_i == 1

          # If All ending conditions should be true
          if params[:end_offer_if] == 'All'
            ends = {}
            params[:end][:targets].each_with_index do |e, i|
              case "#{e}"
                when 'Date'
                  ends[:date] << "m.created_at.#{params[:end][:conds][i]}#{params[:end][:values][i]}"
                when 'Total number of offer use'
                  ends[:max_use] = params[:end][:values][i]
              end
            end

            save_rule(variables, conditions.dup, ends)

          # If Any ending conditions should be true
          elsif params[:end_offer_if] == 'Any'
            params[:end][:targets].each_with_index do |e, i|
              ends = {}
              case "#{e}"
                when 'Date'
                  ends[:date] = "m.created_at.#{params[:end][:conds][i]}#{params[:end][:values][i]}"
                when 'Total number of offer use'
                  ends[:max_use] = params[:end][:values][i]
              end
              save_rule(variables, conditions.dup, ends)
            end
          end

        # If there are any ending conditions
        else
          save_rule(variables, conditions.dup)
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

 def build_a_rule(rule_target, index, conditions)
    case "#{rule_target}"
    when "0"
      target = "m.weight"
    when "1"
      target =  "m.products.type"
    when "2"
      target =  "m.user.country_id"
    end

    if params[:rule][:values][index].to_i == 0
      value = "'#{params[:rule][:values][index]}'"
    else
      value = params[:rule][:values][index]
    end
    conditions << "#{target}.#{params[:rule][:conds][index]}(#{value})"
  end

  def save_rule(variables, conditions, ends = {})

    conditions << ends[:date] unless ends[:date].nil?

    rule = ShippingRule.new
    rule.name = params[:rule_builder][:name]
    rule.description = params[:rule_builder][:description]
    rule.conditions = "[#{conditions.join(', ')}]"
    rule.variables = variables
    rule.max_use = ends[:max_use].nil? ? 0 : ends[:max_use]
    rule.save
  end

end
