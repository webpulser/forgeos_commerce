# ==== Subclasses
# * <tt>AddressDelivery</tt>
# * <tt>AddressInvoice</tt>
#
# ==== Associate
# * <tt>civility</tt> - <i>Civility</i>
# * <tt>country</tt> - <i>TODO</i>
# * <tt>user</tt> - <i>User</i>
#
# ==== Attributes
# * <tt>name</tt>
# * <tt>firstname</tt>
# * <tt>address</tt>
# * <tt>address_2</tt>
# * <tt>zip_code</tt>
# * <tt>city</tt>
# * <tt>type</tt>
class Address < ActiveRecord::Base
  
  belongs_to :civility
  belongs_to :user
  belongs_to :country
  has_one :order

  validates_presence_of :country_id, :civility_id, :address, :city, :designation

  # Returns address in a string <i>#{firstname} #{name} #{address} #{zip_code} #{city}</i>
  def to_s
    "#{civility.name} #{firstname} #{name} #{address} #{zip_code} #{city} #{country.name.upcase}"
  end
  
  def kind
    read_attribute(:type)
  end
  
  def kind=(kind)
    write_attribute(:type, kind)
  end 
end
