module RailsCommerce
  # ==== Subclasses
  # * <tt>RailsCommerce::AddressDelivery</tt>
  # * <tt>RailsCommerce::AddressInvoice</tt>
  #
  # ==== Associate
  # * <tt>civility</tt> - <i>RailsCommerce::Civility</i>
  # * <tt>country</tt> - <i>TODO</i>
  # * <tt>user</tt> - <i>RailsCommerce::User</i>
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
    set_table_name "rails_commerce_addresses"
    
    belongs_to :civility, :class_name => 'RailsCommerce::Civility'
    belongs_to :user
    belongs_to :country, :class_name => 'RailsCommerce::Country'

    validates_presence_of :country_id, :civility_id, :address, :city

    # Returns address in a string <i>#{firstname} #{name} #{address} #{zip_code} #{city}</i>
    def to_s
      "#{firstname} #{name} #{address} #{zip_code} #{city}"
    end
  end
end
