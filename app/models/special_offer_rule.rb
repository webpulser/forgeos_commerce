class SpecialOfferRule < Rule
  has_and_belongs_to_many :products
  has_and_belongs_to_many :shipping_method_details
end