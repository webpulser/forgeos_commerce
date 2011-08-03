# This model use ActsAsStateMachine
#
# ==== belongs_to
# * <tt>address_delivery</tt> - <i>AddressDelivery</i>
# * <tt>address_invoice</tt> - <i>AddressInvoice </i>
# * <tt>user</tt> - <i>User</i>
#
# ==== has_many
# * <tt>order_details</tt> - <i>OrdersDetail</i>
#
# ==== Attributes
# * <tt>transporter</tt> - <i>Transporter</i> name
# * <tt>transporter_price</tt> - <i>ShippingMethod</i> price
require 'sha1'
require 'CMCIC_Config'
require 'CMCIC_Tpe'
require 'cgi'
class Order < ActiveRecord::Base
  include AASM
  aasm_column :status
  aasm_initial_state :unpaid
  aasm_state :unpaid
  aasm_state :waiting_for_cheque, :after_enter => :waiting_for_cheque_event
  aasm_state :paid, :after_enter => :payment_confirmation
  aasm_state :shipped, :after_enter => :enter_shipping_event
  aasm_state :canceled, :after_enter => :update_patronage
  aasm_state :closed

  aasm_event :pay do
    transitions :to => :paid, :from => [:unpaid, :waiting_for_cheque]
  end

  aasm_event :wait_for_cheque do
    transitions :to => :waiting_for_cheque, :from => :unpaid
  end

  aasm_event :start_shipping do
    transitions :to => :shipped, :from => :paid
  end

  aasm_event :cancel do
    transitions :to => :canceled, :from => [:unpaid, :shipped, :paid]
  end

  aasm_event :close do
    transitions :to => :closed, :from => [:shipped, :canceled]
  end

  has_many :order_details, :dependent => :destroy
  accepts_nested_attributes_for :order_details, :allow_destroy => true
  has_many :products, :through => :order_details

  has_one :order_shipping, :dependent => :destroy
  accepts_nested_attributes_for :order_shipping

  has_one :address_delivery, :dependent => :destroy
  accepts_nested_attributes_for :address_delivery
  has_one :address_invoice, :dependent => :destroy
  accepts_nested_attributes_for :address_invoice

  belongs_to :user
  validates_presence_of :user_id
  validates_associated :address_delivery, :if => :needs_address_delivery?
  validates_associated :address_invoice, :if => :needs_address_invoice?
  validates_associated :order_shipping, :if => :needs_order_shipping?

  define_index do
    indexes status, :sortable => true
    indexes order_details.name, :facet => true,  :sortable => true
    indexes order_details.description, :facet => true,  :sortable => true
    indexes order_details.sku, :facet => true,  :sortable => true
    indexes order_details.price, :facet => true,  :sortable => true
  end

  before_save :update_patronage

  def aasm_current_state_with_event_firing=(state)
    aasm_events_for_current_state.each do |event_name|
      event = self.class.aasm_events[event_name]
      aasm_fire_event(event_name,false) if event && event.all_transitions.any?{ |t| t.to == state || t.to == state.to_sym }
    end
  end

  alias_method :aasm_current_state_with_event_firing, :aasm_current_state

  PAYPAL_CERT_PEM = File.exist?("#{Rails.root}/certs/paypal_cert.pem") ? File.read("#{Rails.root}/certs/paypal_cert.pem") : ''
  APP_CERT_PEM = File.exist?("#{Rails.root}/certs/app_cert.pem") ? File.read("#{Rails.root}/certs/app_cert.pem") : ''
  APP_KEY_PEM = File.exist?("#{Rails.root}/certs/app_key.pem") ? File.read("#{Rails.root}/certs/app_key.pem") : ''

  # GENERATE ENCRYPTED FORM FOR CHECKOUT
  def paypal_encrypted
    paypal = Setting.current.payment_method_setting_with_env(:paypal)
    values = {
      :business => paypal[:email],
      :cmd => '_cart',
      :upload => 1,
      :return => paypal[:url_ok],
      :invoice => id,
      :notify_url => paypal[:auto_response],
      :cert_id => paypal[:cert_id],
      :currency_code => paypal[:currency],
      :handling_cart => self.order_shipping.price.nil? ? 0 : self.order_shipping.price.round(2)
    }
    order_details.all( :group => 'product_id').each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => (item.price).round(2),
        "item_name_#{index+1}" => item.product.name,
        "item_number_#{index+1}" => item.id,
        "quantity_#{index+1}" => item.quantity
      })
    end
    encrypt_for_paypal(values)
  end

  def encrypt_for_paypal(values)
    begin
      signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
      OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
    rescue
      ''
    end
  end


  def cyberplus_encrypted
    ts = Time.now
    cyberplus = Setting.current.payment_method_setting_with_env(:cyberplus)

    payment_config = if cyberplus[:payment_config] =~ /^MULTI:.*count=(\d+)/i and self.payment_plans
      count = $1.to_i
      cyberplus[:payment_config].sub('#PRICE',"#{(total*100).to_i / count}")
    else
      'SINGLE'
    end

    payment = {
      :version => cyberplus[:version],
      :site_id => cyberplus[:site_id],
      :ctx_mode => Setting.current.payment_method_for_test?(:cyberplus) ? 'TEST' : 'PRODUCTION',
      :trans_id => ts.strftime('%H%M%S'),
      :trans_date => ts.strftime('%Y%m%d%H%M%S'),
      :validation_mode => '',
      :capture_delay => '',
      :payment_config => payment_config,
      :payment_cards => cyberplus[:payment_cards],
      :amount => (total*100).to_i,
      :currency => cyberplus[:currency],
      :key => cyberplus[:key],
      :url_cancel => cyberplus[:url_ko],
      :url_success => cyberplus[:url_ok],
      :url_refused => cyberplus[:url_ko],
      :url_return => cyberplus[:url_return],
      :url_referral => cyberplus[:url_referral],
      :order_id => id
    }

    sign = [:version, :site_id, :ctx_mode, :trans_id,
             :trans_date, :validation_mode, :capture_delay,
             :payment_config, :payment_cards, :amount,
             :currency, :key].map{ |key| payment[key] }

    payment[:signature] = SHA1.new(sign.join('+'))
    return payment
  end

  def cmc_cic_encrypted
    cmc_cic = Setting.currency.payment_method_setting_with_env(:cmc_cic)

    sReference = "#{rand(1000)}A#{reference}" # Reference: unique, alphaNum (A-Z a-z 0-9), 12 characters max
    sMontant = '%.2f' % total # Amount : format  "xxxxx.yy" (no spaces)
    sDevise  = "EUR" # Currency : ISO 4217 compliant
    sTexteLibre = ""
    sDate = DateTime.now().strftime("%d/%m/%Y:%H:%M:%S") # transaction date : format dd/mm/YYYY:HH:mm:ss
    sLangue = "FR" # Language of the company code
    sUrlOk = CMCIC_URLOK
    sUrlKo = CMCIC_URLKO
    sUrlReturn = CMCIC_URL_RETURN
    sEmail = user.email # customer email
    sOptions = ""
    oTpe = CMCIC_Tpe.new(sLangue)
    oMac = CMCIC_Hmac.new(oTpe)
    sNbrEch = sDateEcheance1 = sMontantEcheance1 = sDateEcheance2 = sMontantEcheance2 = sDateEcheance3 = sMontantEcheance3 = sDateEcheance4 = sMontantEcheance4 = nil
    sChaineDebug = "V1.04.sha1.rb--[CtlHmac" + oTpe.sVersion + oTpe.sNumero + "]-" + oMac.computeHMACSHA1("CtlHmac" + oTpe.sVersion + oTpe.sNumero) # Control String for support
    sChaineMAC = [oTpe.sNumero, sDate, "#{sMontant}#{sDevise}", sReference, sTexteLibre, oTpe.sVersion, sLangue, oTpe.sCodeSociete, sEmail, sNbrEch, sDateEcheance1, sMontantEcheance1, sDateEcheance2, sMontantEcheance2, sDateEcheance3, sMontantEcheance3, sDateEcheance4, sMontantEcheance4, sOptions].join("*") # Data to certify
    payment = {
      :version => oTpe.sVersion,
      :TPE =>  oTpe.sNumero,
      :date => sDate,
      :montant => "#{sMontant}#{sDevise}",
      :reference => sReference,
      :MAC => oMac.computeHMACSHA1(sChaineMAC),
      :url_retour => sUrlReturn,
      :url_retour_ok => sUrlOk,
      :url_retour_err => sUrlKo,
      :lgue => sLangue,
      :societe => oTpe.sCodeSociete,
      :debug => sChaineDebug,
      :mail => sEmail,
      :bouton => oTpe.sNumero,
      :url_payment => oTpe.sUrlPaiement
    }
    return payment
  end

  def elysnet_encrypted
    setting = Setting.first
    elysnet = Setting.current.payment_settings_with_env(:elysnet)

    parm = "merchant_id=#{elysnet[:merchant_id]}"
    parm += " merchant_country=fr"
    parm += " amount=#{(total*100).to_i}"
    parm += " currency_code=978"
    parm += " pathfile=" + $pathfile
    parm += " normal_return_url=#{elysnet[:url_ok]}"
    parm += " cancel_return_url=#{elysnet[:url_ko]}"
    parm += " automatic_response_url=#{elysnet[:auto_response]}"
    parm += " language=fr"
    parm += " payment_means=CB,1,VISA,1,MASTERCARD,1"
    parm += " header_flag=no"
    parm += " customer_email=#{self.user.email}"
    parm += " order_id=#{self.id}"
    result = `./lib/elysnet/bin/request #{parm}` #execution of request script
    tab = result.split("!")
    payment = tab[3]
    return payment
  end

  # Returns order's amount
  def total(options = {})
    options = {:tax => true,
               :cart_voucher_discount => true,
               :cart_special_offer_discount => true,
               :product_voucher_discount => true,
               :product_special_offer_discount => true,
               :patronage => true,
               :cart_packaging => true,
               :product_packaging => true,
               :with_shipping => true}.update(options.symbolize_keys)

    total = 0
    order_details.each do |order_detail|
      product_price = order_detail.price({:tax => options[:tax], :voucher_discount => options[:product_voucher_discount], :special_offer_discount => options[:product_special_offer_discount], :packaging => options[:product_packaging] })
      total += product_price * order_detail.quantity
    end
    total += order_shipping.price if options[:with_shipping] && order_shipping && order_shipping.price
    total -= self.voucher_discount.to_f || 0 if options[:cart_voucher_discount] && self.voucher_discount
    total -= self.special_offer_discount.to_f || 0 if options[:cart_special_offer_discount] && self.special_offer_discount
    total -= self.patronage_discount.to_f || 0 if options[:patronage]
    total += self.packaging_price.to_f || 0 if options[:cart_packaging]
    total = self.after_total(total, options) if self.respond_to?(:after_total)
    total = 0 if total < 0
    return total
  end

  def discount
    self.total({:cart_voucher_discount => false, :cart_special_offer_discount => false, :product_voucher_discount => false})-self.total
  end

#  def total(with_tax=false, with_currency=true,with_shipping=true,with_special_offer=true, with_voucher=true, with_patronage=true)
#    amount = 0
#    .each do |order_detail|
#      price = order_detail.price(with_tax, with_currency,with_special_offer,with_voucher)
#      amount += price if price
#    end
#    amount += order_shipping.price if with_shipping && order_shipping && order_shipping.price
#    amount -= self.special_offer_discount if with_special_offer && self.special_offer_discount
#    amount -= self.voucher_discount if with_voucher && self.voucher_discount
#    amount -= self.patronage_discount if with_patronage
#    return ("%01.2f" % amount).to_f
#  end

  def taxes
    ("%01.2f" % (total - total(:tax => false))).to_f
  end

  def total_items
    return order_details.length
  end

  def product_names
    count = self.order_details.count
    if count == 1
      return self.order_details.first.name
    else
      return "#{count} #{I18n.t('product', :count => 2)}"
    end
  end

  def weight
    products.sum(:weight)
  end

  def special_offer_discount_products
    return order_details.all(:conditions => ['special_offer_discount_price IS NOT NULL'])
  end

  def voucher_discount_products
    return order_details.all(:conditions =>['voucher_discount_price IS NOT NULL'])
  end

  def patronage_discount
    return read_attribute(:patronage_discount_price) if self.patronage_discount_price
    return 0 unless self.user
    if self.user.has_nephew_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(false,false,true,false,false,false) / 100
      else
        self.user.patronage_discount
      end
    elsif self.user.has_godfather_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(false,false,true,false,false,false) / 100
      else
        self.user.patronage_discount
      end
    else
      0
    end
  end

  def self.from_cart(cart)
    if cart and cart.user_id
      order_details_attributes = cart.cart_items.collect do |cart_product|
        OrderDetail.from_cart_product(cart_product).attributes
      end + Product.find_all_by_id(cart.options[:free_product_ids]).collect do |product|
        OrderDetail.from_free_product(product).attributes
      end

      order = self.find_or_initialize_by_reference(cart.id)
      order.order_details.destroy_all

      order.attributes = {
        :user_id => cart.user_id,
        :voucher_discount => cart.voucher_discount_price,
        :special_offer_discount => cart.special_offer_discount_price,
        :order_details_attributes => order_details_attributes,
        :reference => cart.id
      }

      order.build_address_invoice(cart.address_invoice.attributes.update(:person_id => nil))
      order.build_order_shipping(OrderShipping.from_cart(cart).attributes)

      if cart.options[:colissimo].nil?
        order.build_address_delivery(cart.address_delivery.attributes.update(:person_id => nil))
      else
        order.build_address_delivery(cart.address_from_colissimo.attributes)
      end

      self.after_from_cart(order,cart) if self.respond_to?(:after_from_cart)
      return order
    end
  end

  def valid_shipment?
    # AddressInvoice and AddressDelivery is obligatory for valid an order
    (address_invoice and address_invoice.valid?) and (address_delivery and address_delivery.valid?)
  end

  def valid_for_payment?
    valid_shipment?
  end

  def packaging_price
    #TODO get config from cart config
    0
  end


  def to_colissimo_params
    setting = Setting.first
    colissimo = setting.colissimo_method_list
    require "digest/sha1"
    order_id = "#{rand(1000)}m#{self.reference}"
    cart = Cart.find_by_id(self.reference)

    if transporter = TransporterRule.find_by_id(cart.options[:transporter_rule_id])
      price = transporter.variables
    else
      price = colissimo[:forwarding_charges]
    end

    signature_tmp = "#{colissimo[:fo]}#{self.user.lastname.to_s.parameterize(' ').upcase}#{colissimo[:preparation_time]}#{price}#{self.user_id}#{self.reference}#{order_id}#{colissimo[:sha]}"
    signature = Digest::SHA1.hexdigest(signature_tmp)
    unless user.civility.nil?
      civ = I18n.t("civility.label.#{self.user.civility}").upcase
    else
      civ = 'MR'
    end


    infos = {
        :ceAdress3 => cart.address_delivery.address.to_s.parameterize(' ').upcase,
        :ceAdress4 => cart.address_delivery.address_2.to_s.parameterize(' ').upcase,
        :ceZipCode => cart.address_delivery.zip_code,
        :ceTown => cart.address_delivery.city.to_s.parameterize(' ').upcase,
        #:cePhoneNumber => self.address_delivery.phone,
        :ceCivility => civ,
        :ceName => self.user.lastname.to_s.parameterize(' ').upcase,
        :ceFirstName => self.user.firstname.to_s.parameterize(' ').upcase,
        :ceEmail => self.user.email,
        :trClientNumber => self.user_id,
        :dyForwardingCharges => price,
        :dyPreparationTime => colissimo[:preparation_time],
        :trOrderNumber => self.reference,
        :orderId => order_id,
        :signature => signature,
        :pudoFOId => colissimo[:fo]
    }
    infos
  end

  def update_attributes_from_colissimo(params)
    case params[:DELIVERYMODE]
    when 'DOM', 'RDV', 'DOS'
      self.update_attributes(
        :order_shipping_attributes => { :name => 'So Colissimo', :price =>  params[:DYFORWARDINGCHARGES], :colissimo_type => params[:DELIVERYMODE]},
        :address_delivery_attributes =>{
          :designation => 'So colissimo',
          :civility => params[:CECIVILITY],
          :name => params[:CENAME],
          :firstname => params[:CEFIRSTNAME],
          :city => params[:CETOWN],
          :zip_code => params[:CEZIPCODE],
          :address => params[:CEADRESS3],
          :address_2 => params[:CEADRESS4],
          :country_id => Country.find_by_name('FRANCE').id,
          :form_attributes => { :other_phone => params[:CEPHONENUMBER], :phone => params[:CEPHONENUMBER],:email => params[:CEEMAIL] }

        }
      )
    else
      self.update_attributes(
        :order_shipping_attributes => { :name => 'So Colissimo', :price =>  params[:DYFORWARDINGCHARGES], :colissimo_type => params[:DELIVERYMODE]},
        :address_delivery_attributes => {
          :designation => 'So colissimo',
          :civility => params[:CECIVILITY],
          :name => params[:PRNAME],
          :firstname => params[:CEFIRSTNAME],
          :city => params[:PRTOWN],
          :zip_code => params[:PRZIPCODE],
          :address => params[:PRADRESS1],
          :address_2 => params[:PRADRESS2],
          :country_id => Country.find_by_name('FRANCE').id,
          :form_attributes => { :colisssimo_point_id => params[:PRID], :other_phone => params[:CEPHONENUMBER], :phone => params[:CEPHONENUMBER],:email => params[:CEEMAIL] }
        }
      )
    end
  end


  private

  def payment_confirmation
    if self.user
      # decrement user's patronage_count if its use has patronage
      User.decrement_counter(:patronage_count,self.user.id) if self.user.has_godfather_discount?
      # increment user's godfather patronage_count if its user's first order
      User.increment_counter(:patronage_count,self.user.godfather_id) if self.user.godfather and self.user.orders.count(:conditions => { :status => 'paid' }) == 1
    end
  end

  def waiting_for_cheque_event
  end

  def enter_shipping_event
    #TODO write a generic function for this event
    #Override this function to do what you want
  end

  def update_patronage
    return true unless self.user and self.user.has_patronage_discount?
    case aasm_current_state
    when :unpaid
      # FIXME
      #User.decrement_counter(:patronage_count,self.user.godfather_id)
      self.patronage_discount_price = patronage_discount
    when :canceled
      User.increment_counter(:patronage_count,self.user.godfather_id)
    end
  end

  def needs_order_shipping?
    true
  end

  def needs_address_delivery?
    true
  end

  def needs_address_invoice?
    true
  end
end
