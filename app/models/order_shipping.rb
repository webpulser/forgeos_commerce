class OrderShipping < ActiveRecord::Base
  belongs_to :order

  def self.from_cart(cart)
    options = {}
    if cart.options[:free_shipping] == true
      options[:name] = I18n.t(:free_shipping)
      options[:price] = 0
    elsif transporter = TransporterRule.find_by_id(cart.options[:transporter_rule_id])
      options[:name] = transporter.name
      options[:price] = transporter.variables
    end
    self.new(options)
  end

  def self.from_colissimo(params)
    case params[:DELIVERYMODE]
      when 'DOM', 'RDV', 'DOS'
        self.update_attributes(
          :name => 'So Colissimo', :price =>  params[:DYFORWARDINGCHARGES], :colisssimo_type => params[:DELIVERYMODE]
        )
      else
        self.update_attributes(
          :name => 'So Colissimo', :price =>  params[:DYFORWARDINGCHARGES], :colisssimo_type => params[:DELIVERYMODE]
        )
    end
  end
end
