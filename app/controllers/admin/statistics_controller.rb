class Admin::StatisticsController < Admin::BaseController
  before_filter :products_most_viewed, :only => :index
  before_filter :products_most_sold, :only => :index
  before_filter :customers_new, :only => :index
  before_filter :best_customers, :only => :index

  before_filter :get_graph, :only => :index

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
        :tip => "#{day.to_s(:short)} :<br>#val# #{$currency.html}"
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

  def get_graph
    @graph = open_flash_chart_object(666, 250, admin_statistics_graph_path(:timestamp => params[:timestamp]), true,'/flashes/')
  end

  def generate_graph(element, y_max, colour)
    # Conf for X axis
    steps = 4
    days_step = (@date.count / steps) > 0 ? @date.count / steps : 1

    x_labels = XAxisLabels.new
    x_labels.set_steps(days_step)
    case params[:timestamp]
    when 'week'
      x_labels.labels = @date.collect{|day| day.to_s(:short)}
    else
      x_labels.labels = @date.collect{|day| day.beginning_of_month == day ? day.to_s(:short) : day.to_s(:only_day)}
      x_labels.set_steps(10)
    end
    x_labels.colour = '#7D5223'
    
    x_axis = XAxis.new
    x_axis.colour = '#7D5223'
    x_axis.grid_colour = '#C8A458'
    x_axis.set_steps(days_step)
    x_axis.set_stroke(1)
    x_axis.set_tick_height(0)
    x_axis.set_labels(x_labels)

    # Conf for Y axis
    y_axis = YAxis.new
    y_axis.colour = '#F2B833'
    y_axis.set_range(0, y_max[0], (y_max[0])/4) if y_max
    y_axis.tick_length = 0
    y_axis.stroke = 0

    # Conf for Y right axis 
    y_axis_right = YAxisRight.new
    y_axis_right.set_range(0, y_max[1], (y_max[1])/4) if y_max
    y_axis_right.tick_length = 0
    y_axis_right.stroke = 0
    y_axis_right.colour = '#94CC69'
    y_axis_right.set_label_text("#val# #{$currency.html}")

    # Tooltip
    tooltip = Tooltip.new
    tooltip.set_shadow(false)
    tooltip.stroke = 1
    tooltip.colour = '#000000'
    tooltip.set_background_colour("#ffffff")
    tooltip.set_title_style("{font-size: 10px; font-weight: normal; color: #000000;}")
    tooltip.set_body_style("{font-size: 12px; font-weight: bold; color: #000000;}")

    # Construct chart
    chart = OpenFlashChart.new
    chart.set_bg_colour('#FEF7DB')
    chart.x_axis = x_axis
    chart.y_axis = y_axis
    chart.y_axis_right = y_axis_right
    chart.set_tooltip(tooltip)
    #chart.y_legend = { :text => 'toto' }
    #chart.y_legend_right = { :text => 'tata' }
    if element.is_a?(Array)
      element.each do |data|
        chart.add_element(data)
      end
    else
      chart.add_element(element)
    end

    return chart.render
  end
end
