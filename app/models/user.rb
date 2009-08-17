# This model must to be extend by the model generated by RestfulAuthentication
class User < Person
  validates_presence_of :civility_id, :country_id, :birthday

  has_one :cart
  has_one :wishlist
  has_one :address_delivery, :order => 'id desc'
  has_one :address_invoice, :order => 'id desc'
  
  has_many :addresses
  has_many :address_deliveries, :order => 'id desc'
  has_many :address_invoices, :order => 'id desc'

  has_many :orders, :order => 'id desc'
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'

  def age
    ((Date.today - self.birthday) / 365).floor
  end
end
