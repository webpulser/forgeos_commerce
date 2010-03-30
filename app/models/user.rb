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

  def total_orders
    self.orders.collect(&:total).sum
  end
end
