load File.join(Gem.loaded_specs['forgeos_core'].full_gem_path, 'app', 'models', 'setting.rb')
class Setting < ActiveRecord::Base
  serialize :payment_methods
  serialize :colissimo_methods

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

  def payment_method_availables
    payment_methods.keys.reject { |k| not payment_method_available?(k) }
  end

  def payment_method_for_test?(k)
    payment_methods[k.to_sym] && payment_methods[k.to_sym][:test] == '1'
  end

  def payment_method_env(k)
    payment_method_for_test?(k) ? :development : :production
  end

  def payment_method_settings(k)
    payment_methods[k.to_sym] if payment_method_available?(k)
  end

  def payment_method_settings_with_env(k)
    payment_method_settings(k)[payment_method_env(k)] if payment_method_available?(k)
  end

  def colissimo_method_available?
    colissimo_methods[:active] == '1' if colissimo_methods
  end

end
