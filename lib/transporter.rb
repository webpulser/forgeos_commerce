require 'ruleby'
class Transporter < Ruleby::Rulebook

  attr_writer :transporter_ids, :order
  
  def rules
    TransporterRule.find_all_by_active(true).each do |transporter|
      condition = transporter.conditions
      condition.gsub!(/Cart/,'Order') if @order
      rule eval(condition) do |context|
        if @order && @order.address_delivery && transporter.country && transporter.country.id == @order.address_delivery.country.id
          @transporter_ids << transporter.id
        else
          @transporter_ids << transporter.id
        end
      end
    end
    @transporter_ids
  end
  
end
