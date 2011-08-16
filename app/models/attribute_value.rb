class AttributeValue < ActiveRecord::Base
  translates :value

  belongs_to :attribute, :readonly => true
  validates_associated :attribute

  has_and_belongs_to_many_attachments

  has_and_belongs_to_many :products
end
