class Admin::StatisticsController < Admin::BaseController
  before_filter :products_most_viewed, :only => :index
  before_filter :products_most_sold, :only => :index

private
  def products_most_viewed
    @products_most_viewed = Forgeos::Commerce::Statistics.products_most_viewed(@date,10)
  end

  def products_most_sold
    @products_most_sold = Forgeos::Commerce::Statistics.products_most_sold(@date,10)
  end

end
