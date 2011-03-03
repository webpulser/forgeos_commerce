class Admin::StatisticsController < Admin::BaseController
  before_filter :products_most_viewed, :only => :index
  before_filter :products_most_sold, :only => :index
  before_filter :customers_new, :only => :index
  before_filter :best_customers, :only => :index

  # generates the ofc2 graph
  def graph
    get_date
    # visitors
    visitors = @date.collect{|day| Forgeos::Statistics.total_of_visitors(day)}

    # Bar for visitors
    bar = Bar.new
    bar.values  = visitors
    bar.tooltip = "#val# #{I18n.t('visitor', :count => 2)}"
    bar.colour  = '#F2B833'

    # Conf for Y left axis
    # calculates max number of visitors
    max_visitors = visitors.flatten.compact.max.to_i
    max_count_visitors = max_visitors > 0 ? max_visitors : 5

    sales = @date.collect do |day| 
      { :value => Forgeos::Commerce::Statistics.total_of_sales(day),
        :tip => "#{day.to_s(:short)} :<br>#val# #{current_currency.html}"
      }
    end

    # Line Dot for sales
    line_dot = Line.new
    line_dot.text = I18n.t("sale", :count => 2)
    line_dot.width = 4
    line_dot.colour = '#94CC69'
    line_dot.dot_size = 5
    line_dot.values = sales
    line_dot.set_axis('right')
    line_dot.dot_style = { :type => 'solid-dot', :colour => "#94CC69" }

    # Conf for Y right axis
    # calculates max number of sales
    max_sales = sales.collect{ |sale| sale[:value] }.flatten.compact.max.to_i
    max_count_sales = max_sales > 0 ? max_sales : 5

    return render :json => generate_graph([bar,line_dot], [max_count_visitors,max_count_sales], '#F7BD2E')
  end

private
  def products_most_viewed
    @products_most_viewed = Forgeos::Commerce::Statistics.products_most_viewed(@date,10)
  end

  def products_most_sold
    @products_most_sold = Forgeos::Commerce::Statistics.products_most_sold(@date,10)
  end

  def customers_new
      @customers_new = Forgeos::Commerce::Statistics.new_customers(@date, 5)
  end

  def best_customers
      @best_buyers = Forgeos::Commerce::Statistics.best_customers(@date, 5)
  end
end
