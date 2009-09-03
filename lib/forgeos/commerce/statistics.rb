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
    end
  end
end
