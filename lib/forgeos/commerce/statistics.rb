module Forgeos
  module Commerce
    class Statistics
      def self.total_of_sales(date = nil)
        conditions = { :status => %w(paid accepted shipped closed) }
        if date
          if date.kind_of?(Date)
            conditions[:created_at] = date.beginning_of_day..date.end_of_day
          else
            conditions[:created_at] = date
          end
        end
        Order.all(:conditions => conditions).collect(&:total).sum
      end

      def self.products_most_viewed(date,limit = nil)
        ProductViewedCounter.sum(:counter,
          :conditions => { :date => date },
          :order => 'sum_counter DESC',
          :limit => limit,
          :group => 'element_id'
        )
      end

      def self.products_most_sold(date,limit = nil)
        ProductSoldCounter.sum(:counter,
          :conditions => { :date => date },
          :order => 'sum_counter DESC',
          :limit => limit,
          :group => 'element_id'
        )
      end
    end
  end
end
