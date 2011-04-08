class OrderShipping < ActiveRecord::Base
  belongs_to :order

  def self.from_cart(cart)
    options = {}

    unless cart.options[:colissimo].nil?
      params= cart.options[:colissimo]
      options[:name] = 'So Colissimo'
      options[:price] = params['DYFORWARDINGCHARGES']
      options[:colissimo_type] = params['DELIVERYMODE']
    else
      if cart.options[:free_shipping] == true
        options[:name] = I18n.t(:free_shipping)
        options[:price] = 0
      elsif transporter = TransporterRule.find_by_id(cart.options[:transporter_rule_id])
        options[:name] = transporter.name
        options[:price] = transporter.variables
      end
    end

    self.new(options)
  end

end
