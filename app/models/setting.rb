require File.join(Rails.plugins[:forgeos_core].directory,'app','models','setting')
class Setting < ActiveRecord::Base
  before_save :update_so_colissimo_methods
  serialize :payment_methods
  serialize :colissimo_methods

  def colissimo_method_list
    if self.colissimo_methods
      return YAML.load(self.colissimo_methods)
    else
     return {}
    end
  end

  def cheque_message(order)
    return "" unless order.is_a? Order
    if payment_method_available?(:cheque)
      message = payment_methods[:cheque][:message]
      message = message.gsub('#{ORDER_ID}', order.reference.to_s)
      message = message.gsub('#{USER_NAME}', order.user.fullname)
    else
      message = ""
    end
    message
  end

  def payment_method_available?(k)
    payment_methods[k.to_sym] && payment_methods[k.to_sym][:active] == '1'
  end

  def payment_method_for_test?(k)
    payment_methods[k.to_sym] && payment_methods[k.to_sym][:test] == '1'
  end

  def payment_method_env(k)
    payment_method_for_test?(k) ? :development : :production
  end

  def payment_method_settings(k)
    payment_methods[k.to_sym][payment_method_env(k)] if payment_method_available?(k)
  end

  def payment_method_settings_with_env(k)
    payment_methods[k.to_sym][payment_method_env(k)][payment_method_env(k)] if payment_method_available?(k)
  end

  def payment_methods
    read_attribute(:payment_methods)
  end

private

  def update_so_colissimo_methods
    unless self.colissimo_methods.blank?
      colissimo = {
        :active => colissimo_methods[:active].to_i,
        :sha => colissimo_methods[:sha],
        :forwarding_charges => colissimo_methods[:forwarding_charges],
        :preparation_time => colissimo_methods[:preparation_time],
        :urlok => colissimo_methods[:urlok],
        :urlko => colissimo_methods[:urlko],
        :fo => colissimo_methods[:fo],
        :url_prod => colissimo_methods[:url_prod],
        :url_test => colissimo_methods[:url_test]
      }
      self.colissimo_methods = colissimo
    end
  end
end
