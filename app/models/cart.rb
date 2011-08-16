class Cart < ActiveRecord::Base
  attr_accessor :voucher_discount, :voucher_discount_price, :voucher
  attr_accessor :special_offer_discount, :special_offer_discount_price
  attr_accessor :free_shipping

  has_many :cart_items, :dependent => :destroy
  has_many :products, :through => :cart_items

  serialize :options

  belongs_to :user

  def add_product(product,quantity=nil)
    return false if product.nil? || product.new_record?
    add_product_id(product.id,quantity)
  end

  def add_product_id(product_id,quantity=1)
    if cart_item = cart_items.find_by_product_id(product_id)
      cart_item.increment(:quantity, quantity)
    else
      CartItem.create(:product_id => product_id, :quantity => quantity, :cart_id => self.id)
    end
  end

  def remove_product(product,quantity=nil)
    remove_product_id(product.id,quantity)
  end

  def remove_product_id(product_id, quantity = 1)
    if cart_item = cart_items.find_all_by_product_id(product_id)
      cart_item.decrement(:quantity, quantity)
      cart_item.destroy if cart_item.quantity.zero?
    else
      false
    end
  end


  # Empty this cart
  def to_empty
    cart_items.destroy_all
  end

  # Returns true if cart is empty, returns false else
  def is_empty?
    total_items == 0
  end

  def taxes
    #total(true) - total(false)
  end

  def discount
    total(:cart_voucher_discount => false, :cart_special_offer_discount => false, :product_voucher_discount => false) - total
  end

  def total(*args)
    passed_options = args.extract_options!
    options = {
      :tax => true,
      :cart_voucher_discount => true,
      :cart_special_offer_discount => true,
      :product_voucher_discount => true,
      :product_special_offer_discount => true,
      :patronage => true,
      :cart_packaging => true,
      :product_packaging=> true
    }.update(passed_options.symbolize_keys)

    total = 0.0

    cart_items.each do |cart_product|
      product_price = cart_product.product.price(
        :tax => options[:tax],
        :voucher_discount => options[:product_voucher_discount],
        :special_offer_discount => options[:product_special_offer_discount],
        :packaging => options[:product_packaging]
      )
      total += product_price * cart_product.quantity
    end

    total -= self.voucher_discount_price.to_f || 0.0 if options[:cart_voucher_discount]
    total -= self.special_offer_discount_price.to_f || 0.0 if options[:cart_special_offer_discount]
    total -= self.patronage_discount.to_f || 0.0 if options[:patronage]
    total += self.packaging_price.to_f || 0.0 if options[:cart_packaging]

    total = self.after_total(total, options) if self.respond_to?(:after_total)

    total = 0.0 if total < 0
    total
  end

  def packaging_price
     #TODO get carts options from config
    return 0
  end

  def patronage_discount
    return 0 unless self.user
    if self.user.has_nephew_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(:packaging => false, :tax => false) / 100.0
      else
        self.user.patronage_discount
      end
    elsif self.user.has_godfather_discount?
      if Setting.first.nephew_discount_percent?
        self.user.patronage_discount * total(:packaging => false, :tax => false) / 100.0
      else
        self.user.patronage_discount
      end
    else
      0
    end
  end

  # Returns weight of this cart
  def weight(product=nil)
    if product.nil?
      cart_items.map(&:weight).sum
    elsif cart_item = cart_items.find_by_product_id(product.id)
      cart_item.weight
    else
      0
    end
  end

  def total_items
    return cart_items.size
  end

  def discount_cart(discount, percent=nil)
    percent.nil? ? self.update_attributes(:discount => discount) : self.update_attributes(:discount => discount, :percent => 1)
  end

  def address_invoice
    AddressInvoice.find_by_id(options[:address_invoice_id])
  end

  def address_delivery
    AddressDelivery.find_by_id(options[:address_delivery_id])
  end

  def transporter
    TransporterRule.find_by_id(options[:transporter_rule_id])
  end

  def options
    read_attribute(:options)
  end

  def transporter_id
    return 0 unless options[:transporter_rule_id]
    options[:transporter_rule_id].to_i
  end

  def address_from_colissimo
    if params = self.options[:colissimo]
      case params[:DELIVERYMODE]
        when 'DOM', 'RDV', 'DOS'
          AddressDelivery.create(
            :designation => 'So colissimo',
            :civility => params['CECIVILITY'],
            :name => params['CENAME'],
            :firstname => params['CEFIRSTNAME'],
            :city => params['CETOWN'],
            :zip_code => params['CEZIPCODE'],
            :address => params['CEADRESS3'],
            :address_2 => params['CEADRESS4'],
            :country_id => Country.find_by_name('FRANCE').id,
            :form_attributes => { :other_phone => params['CEPHONENUMBER'], :phone => params['CEPHONENUMBER'],:email => params['CEEMAIL'] }
          )
        else
          AddressDelivery.create(
            :designation => 'So colissimo',
            :civility => params['CECIVILITY'],
            :name => params['PRNAME'],
            :firstname => params['CEFIRSTNAME'],
            :city => params['PRTOWN'],
            :zip_code => params['PRZIPCODE'],
            :address => params['PRADRESS1'],
            :address_2 => params['PRADRESS2'],
            :country_id => Country.find_by_name('FRANCE').id,
            :form_attributes => { :colisssimo_point_id => params['PRID'], :other_phone => params['CEPHONENUMBER'], :phone => params['CEPHONENUMBER'], :email => params['CEEMAIL'] }
          )
      end
    end
  end
end
