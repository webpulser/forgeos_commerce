# This model must to be extend by the model generated by RestfulAuthentication
class User < Person
  sortable_attachments

  has_one :cart
  has_one :wishlist
  has_one :address_delivery, :order => 'id desc'
  has_one :address_invoice, :order => 'id desc'
  
  has_many :addresses
  has_many :address_deliveries, :order => 'id desc'
  has_many :address_invoices, :order => 'id desc'

  has_many :orders, :order => 'id desc'
end
