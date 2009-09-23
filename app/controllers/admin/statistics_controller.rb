class Admin::StatisticsController < Admin::BaseController
  before_filter :products_most_viewed, :only => :index
  before_filter :products_most_sold, :only => :index

  before_filter :get_visitors_and_sales_graphs, :only => :index
  before_filter :get_days_count_and_days, :only => [:visitors_graph, :sales_graph]

  # generates the ofc2 visitors graph
  def visitors_graph
    # visitors
    visitors = []
    (1..@days_count).each do |day|
      date = Date.new(@today.year, @today.month, day)
      visitors << Forgeos::Statistics.total_of_visitors(date)
    end

    # Bar for visitors
    bar = Bar.new
    bar.values  = visitors
    bar.tooltip = "#x_label#<br>#val# #{I18n.t('visitor', :count => 2)}"
    bar.colour  = '#F2B833'

    # Conf for Y left axis
    # calculates max number of visitors
    max = visitors.flatten.compact.max.to_i
    max_count = max > 0 ? max : 5

    return render :text => generate_graph(bar, max_count, '#F7BD2E')
  end

  # generates the ofc2 sales graph
  def sales_graph
    # sales
    sales = []
    (1..@days_count).each do |day|
      date = Date.new(@today.year, @today.month, day)
      sales << Forgeos::Commerce::Statistics.total_of_sales(date)
    end

    # Line Dot for sales
    line_dot = LineDot.new
    line_dot.text = I18n.t("sale", :count => 2)
    line_dot.tooltip = "#x_label#<br>#val# #{I18n.t('currency.' + $currency.name, :count => 2)}"
    line_dot.width = 4
    line_dot.colour = '#94CC69'
    line_dot.dot_size = 5
    line_dot.values = sales
    line_dot.set_axis('right')

    # Conf for Y right axis
    # calculates max number of sales
    max = sales.flatten.compact.max.to_i
    max_count = max > 0 ? max : 5

    return render :text => generate_graph(line_dot, max_count, '#92CC60')
  end

private
  def products_most_viewed
    @products_most_viewed = Forgeos::Commerce::Statistics.products_most_viewed(@date,10)
  end

  def products_most_sold
    @products_most_sold = Forgeos::Commerce::Statistics.products_most_sold(@date,10)
  end

  def get_visitors_and_sales_graphs
    @visitors_graph = open_flash_chart_object(666, 187, admin_statistics_visitors_graph_url)
    @sales_graph = open_flash_chart_object(666, 187, admin_statistics_sales_graph_url)
  end

  def get_days_count_and_days
    @today = Date.current
    case params[:period]
    when 'week'
      @days_count = 7
      day_start = Date.new(@today.year, @today.month, @today.day - @today.cwday + 1)
    else # month
      @days_count = Time.days_in_month(@today.month)
      day_start = Date.new(@today.year, @today.month, 1)
    end
    @days = day_start..(day_start + @days_count - 1)
  end

  def generate_graph(element, y_max, colour)
    # Conf for X axis
    steps = 4
    days_step = @days_count / steps

    x_labels = XAxisLabels.new
    x_labels.set_steps(days_step)
    case params[:period]
    when 'week'
      x_labels.labels = @days.collect{|day| day.to_s(:only_day)}
    else
      x_labels.labels = @days.collect{|day| day.to_s(:long_ordinal)}
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
    y_axis.set_range(0, y_max, (y_max)/4) if y_max
    y_axis.tick_length = 0
    y_axis.stroke = 0
    y_axis.set_label_text("#val# #{$currency.name}")

    # Tooltip
    tooltip = Tooltip.new
    tooltip.set_shadow(false)
    tooltip.stroke = 1
    tooltip.colour = colour
    tooltip.set_background_colour("#ffffff")
    tooltip.set_title_style("{font-size: 10px; font-weight: normal; color: #000000;}")
    tooltip.set_body_style("{font-size: 12px; font-weight: bold; color: #{colour};}")

    # Construct chart
    chart = OpenFlashChart.new
    chart.set_bg_colour('#FEF7DB')
    chart.x_axis = x_axis
    chart.y_axis = y_axis
    chart.set_tooltip(tooltip)
    chart.add_element(element)

    return chart.to_s
  end
end
