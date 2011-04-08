require 'ruleby'
class Transporter < Ruleby::Rulebook

  attr_writer :transporter_ids, :orderi, :cart
  
  def rules
    TransporterRule.find_all_by_active(true).each do |transporter|
      condition = transporter.conditions
      condition.gsub!(/Cart/,'Order') unless @cart
      rule eval(condition) do |context|
        if @cart && @cart.address_delivery && !transporter.geo_zones.empty? && transporter.geo_zones.map(&:id).include?(@cart.address_delivery.country.id)
          @transporter_ids << transporter.id
        elsif @cart && @cart.address_delivery && transporter.geo_zones.empty?
          p 'skipped'
        elsif @cart && @cart.address_delivery && !transporter.geo_zones.empty? && !transporter.geo_zones.map(&:id).include?(@cart.address_delivery.country.id)
          p 'skipped'
        else
          @transporter_ids << transporter.id
        end
      end
    end
    @transporter_ids
  end
  
end
