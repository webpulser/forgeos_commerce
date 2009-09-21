module Forgeos
  module Commerce
    class Statistics
      def self.total_of_sales_for_day(date)
        Order.all(:conditions => ['DATE(created_at) = DATE(?) AND status IN (?)',date,%w(paid accepted sended closed)]).collect(&:total).sum
      end

      def self.total_of_sales_for_week(date)
        Order.all(:conditions => ['YEARWEEK(created_at) = YEARWEEK(?) AND status IN (?)',date,%w(paid accepted sended closed)]).collect(&:total).sum
      end

      def self.total_of_sales_for_month(date)
        Order.all(:conditions => ['YEAR(created_at) = YEAR(?) AND MONTH(created_at) = MONTH(?) AND status IN (?)',date,date,%w(paid accepted sended closed)]).collect(&:total).sum
      end

      def self.total_of_sales
        Order.all(:conditions => { :status => %w(paid accepted sended closed) }).collect(&:total).sum
      end

      def self.products_most_viewed_for_month(date,limit)
        Product.all(
          :conditions => ['YEAR(date) = YEAR(?) AND MONTH(date) = MONTH(?)',date,date],
          :order => 'counter DESC',
          :limit => limit,
          :joins => 'INNER JOIN statistic_counters ON (statistic_counters.type = "ProductViewedCounter" AND statistic_counters.element_id = products.id AND statistic_counters.element_type = "Product")'
        )
      end

      def self.products_most_sold_for_month(date,limit)
        Product.all(
          :conditions => ['YEAR(date) = YEAR(?) AND MONTH(date) = MONTH(?)',date,date],
          :order => 'counter DESC',
          :limit => limit,
          :joins => 'INNER JOIN statistic_counters ON (statistic_counters.type = "ProductSoldCounter" AND statistic_counters.element_id = products.id AND statistic_counters.element_type = "Product")'
        )
      end
    end
  end
end
