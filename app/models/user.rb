require File.join(Rails.plugins['forgeos_core'].directory,'app','models','user')
class User < Person
  has_one :cart
  has_one :wishlist
  has_one :address_delivery, :order => 'id desc'
  has_one :address_invoice, :order => 'id desc'

  has_many :address_deliveries, :order =>  'id desc'
  has_many :address_invoices, :order => 'id desc'
  has_many :orders, :order => 'id desc'

  accepts_nested_attributes_for :address_deliveries, :address_delivery, :address_invoices, :address_invoice
  attr_accessible :address_deliveries_attributes, :address_delivery_attributes, :address_invoices_attributes, :address_invoice_attributes
  belongs_to :godfather, :class_name => 'User'
  has_many :nephews, :foreign_key => 'godfather_id', :class_name => 'User'

  attr_accessible :godfather_id, :patronage_count

  def total_orders
    self.orders.collect(&:total).sum
  end

  def has_nephew_discount?
    self.godfather and self.orders.find_all_by_status(%w(unpaid paid shipped)).empty?
  end

  def has_godfather_discount?
    self.patronage_count > 0
  end

  def has_patronage_discount?
    has_nephew_discount? or has_godfather_discount?
  end

  def patronage_discount
    if has_nephew_discount?
      Setting.first.nephew_discount_price
    elsif has_godfather_discount?
      Setting.first.godfather_discount_price
    else
      0
    end
  end

  def godfather=(user)
    self.godfather_id = user.id
    User.increment_counter(:patronage_count,user.id)
  end
end
