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

      def self.total_of_sold_products(date)
        ProductSoldCounter.sum(:counter, :conditions => { :date => date })
      end

      def self.best_customers(date, limit = nil)
        new_hash = {}
        OrderDetail.sum(:price,
          :conditions => { :orders => { :status => %w(paid shipped closed), :updated_at => date } },
          :include => :order,
          :group => 'orders.user_id',
          :order => 'sum_price DESC'
        ).each_with_index do |item,index|
          break if index < limit
          new_hash[item.first] = item.last
        end
        return new_hash
      end

      def self.new_customers(date, limit = nil)
        User.all(
          :conditions => { :created_at => date },
          :order => 'created_at DESC',
          :limit => limit
        )
      end

    end
  end
end
