require File.join(Rails.root,'vendor','plugins','forgeos_core','app','models','setting')
class Setting < ActiveRecord::Base
  before_save :update_payment_methods, :update_so_colissimo_methods
  serialize :payment_methods
  serialize :colissimo_methods
  
  def payment_method_list
    if self.payment_methods
      return YAML.load(self.payment_methods)
    else
     return {}
    end
  end
 
  def colissimo_method_list
    if self.colissimo_methods
      return YAML.load(self.colissimo_methods)
    else
     return {}
    end
  end
 
  def cheque_message(order)
    return "" unless order.is_a? Order
    if payment_method_list[:cheque] && payment_method_list[:cheque][:active]
      message = payment_method_list[:cheque][:message]
      message = message.gsub('#{ORDER_ID}', order.reference.to_s)
      message = message.gsub('#{USER_NAME}', order.user.fullname)
    else
      message = ""
    end
    message
  end
  
private

  def update_so_colissimo_methods
    unless self.colissimo_methods.empty?
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

  def update_payment_methods
    unless self.payment_methods.empty?
      payment = {
        :cheque => {
          :image => payment_methods[:cheque_image],
          :active => payment_methods[:cheque].to_i,
          :message => payment_methods[:cheque_message]
        },
        :paypal => {
          :image => payment_methods[:paypal_image],
          :active => payment_methods[:paypal].to_i,
          :test => payment_methods[:paypal_test].to_i,
          :development => {
            :email => payment_methods[:paypal_dev_email],
            :secret => payment_methods[:paypal_dev_secret],
            :cert_id => payment_methods[:paypal_dev_cert_id],
            :url => payment_methods[:paypal_dev_url],
            :url_ok => payment_methods[:paypal_dev_url_ok],
            :auto_response => payment_methods[:paypal_dev_auto_response],
            :currency => payment_methods[:paypal_dev_currency]
          },
          :production => {
            :email => payment_methods[:paypal_prod_email],
            :secret => payment_methods[:paypal_prod_secret],
            :cert_id => payment_methods[:paypal_prod_cert_id],
            :url => payment_methods[:paypal_prod_url],
            :url_ok => payment_methods[:paypal_prod_url_ok],
            :auto_response => payment_methods[:paypal_prod_auto_response],
            :currency => payment_methods[:paypal_prod_currency]
          }
        },
        :cmc_cic => {
          :image => payment_methods[:cmc_cic_image],
          :active => payment_methods[:cmc_cic].to_i,
          :test => payment_methods[:cmc_cic_test].to_i,
          :development => {
            :cle => payment_methods[:cmc_cic_dev_cle],
            :tpe => payment_methods[:cmc_cic_dev_tpe],
            :version => payment_methods[:cmc_cic_dev_version],
            :serveur => payment_methods[:cmc_cic_dev_serveur],
            :code_societe => payment_methods[:cmc_cic_dev_code_societe],
            :url_ok => payment_methods[:cmc_cic_dev_url_ok],
            :url_ko => payment_methods[:cmc_cic_dev_url_ko],
            :url_return => payment_methods[:cmc_cic_dev_url_return]
          },
          :production => {
            :cle => payment_methods[:cmc_cic_prod_cle],
            :tpe => payment_methods[:cmc_cic_prod_tpe],
            :version => payment_methods[:cmc_cic_prod_version],
            :serveur => payment_methods[:cmc_cic_prod_serveur],
            :code_societe => payment_methods[:cmc_cic_prod_code_societe],
            :url_ok => payment_methods[:cmc_cic_prod_url_ok],
            :url_ko => payment_methods[:cmc_cic_prod_url_ko],
            :url_return => payment_methods[:cmc_cic_prod_url_return]
          }
        },
        :cyberplus => {
          :image => payment_methods[:cyberplus_image],
          :active => payment_methods[:cyberplus].to_i,
          :test => payment_methods[:cyberplus_test].to_i,
          :development => {
            :key => payment_methods[:cyberplus_dev_key],
            :currency => payment_methods[:cyberplus_dev_currency],
            :version => payment_methods[:cyberplus_dev_version],
            :site_id => payment_methods[:cyberplus_dev_site_id],
            :payment_cards => payment_methods[:cyberplus_dev_payment_cards],
            :payment_config => payment_methods[:cyberplus_dev_payment_config],
            :url_ok => payment_methods[:cyberplus_dev_url_ok],
            :url_ko => payment_methods[:cyberplus_dev_url_ko],
            :url_return => payment_methods[:cyberplus_dev_url_return],
            :url_referral => payment_methods[:cyberplus_dev_url_referral]
          },
          :production => {
            :key => payment_methods[:cyberplus_prod_key],
            :currency => payment_methods[:cyberplus_prod_currency],
            :version => payment_methods[:cyberplus_prod_version],
            :site_id => payment_methods[:cyberplus_prod_site_id],
            :payment_cards => payment_methods[:cyberplus_prod_payment_cards],
            :payment_config => payment_methods[:cyberplus_prod_payment_config],
            :url_ok => payment_methods[:cyberplus_prod_url_ok],
            :url_ko => payment_methods[:cyberplus_prod_url_ko],
            :url_return => payment_methods[:cyberplus_prod_url_return],
            :url_referral => payment_methods[:cyberplus_prod_url_referral]
          }
        },
        :elysnet => {
          :image => payment_methods[:elysnet_image],
          :active => payment_methods[:elysnet].to_i,
          :test => payment_methods[:elysnet_test].to_i,
          :development => {
            :url_ok => payment_methods[:elysnet_dev_url_ok],
            :url_ko => payment_methods[:elysnet_dev_url_ko],
            :auto_response => payment_methods[:elysnet_dev_auto_response],
            :merchant_id => payment_methods[:elysnet_dev_merchant_id]
          },
          :production => {
            :url_ok => payment_methods[:elysnet_production_url_ok],
            :url_ko => payment_methods[:elysnet_production_url_ko],
            :auto_response => payment_methods[:elysnet_production_auto_response],
            :merchant_id => payment_methods[:elysnet_production_merchant_id]
          }
        }
      }
      self.payment_methods = payment
    end
  end
end
